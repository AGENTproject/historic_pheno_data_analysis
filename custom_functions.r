preprocess <- function(data_file){
                experiments <- read_xlsx(data_file, sheet = "Experiment") |> rename_with(~tolower(gsub(" ", "_", .x)))
                observations <- read_xlsx(data_file, sheet = "Observed scores") |> rename_with(~tolower(gsub(" ", "_", .x)))
                return(observations |> left_join(experiments, by = "experiment_id") |>
                       unite("campaign", c(year_start,year_end), sep="-") |>
                       select(accenumb:campaign) |> drop_na(accenumb, campaign) |> 
                       distinct() |> arrange(campaign, accenumb))}

make_data_sub <- function(full_df, trait){
                data_sub <- full_df |> select("accenumb", "campaign", all_of(trait)) |> drop_na() |> distinct() |>
                group_by(accenumb) |> filter(n()>1) |> group_by(campaign) |> filter(n()>1) |> 
                mutate_at(vars(accenumb, campaign), factor)
                cat(nrow(data_sub), trait, "rows kept\n") 
                return(as.data.frame(data_sub))}

visualise_trait <- function(data_sub, geom){
                trait <- colnames(data_sub)[3]
                trait_title <- trait |> str_replace_all("_", " ") |> str_to_title()
                plot(ggplot(data_sub, aes(campaign,.data[[trait]])) + geom_jitter()
                     + theme(axis.text.x=element_text(angle=90,vjust=0.5,hjust=0.5))
                     + labs(title = trait_title, subtitle = "Trait values per campaign",))
                plot(ggplot(data_sub, aes(.data[[trait]])) + geom
                     + labs(title = trait_title, subtitle = "Distribution of trait values",))}

get_campaign_effect <- function(asreml_campaign){
                intercept_index <- nrow(asreml_campaign$coeff$fixed)
                intercept <- asreml_campaign$coeff$fixed[intercept_index]
                campaign_effect <- asreml_campaign$coeff$fixed[-intercept_index,] + intercept
                return(campaign_effect |> as.data.frame() |> rownames_to_column() |> 
                        mutate(campaign = str_sub(rowname,10)) |> 
                        select(campaign, campaign_effect))}

get_error_var <- function(asreml_campaign){
                summary(asreml_campaign)$varcomp |> slice(2:n()) |> select(std.error) |> 
                as_tibble() |> rename("error_variance"="std.error")}

make_CV_df <- function(campaign_effect, error_var){
                tibble(campaign_effect, error_var) |> 
                mutate(coefficient_of_variation=sqrt(error_variance)/campaign_effect) |> 
                mutate(standardized_CV=scale(coefficient_of_variation)[,1])}

correct_I <- function(data_sub, CV_df){
                outlier_campaigns <- CV_df |> filter(standardized_CV > 3.5) |> select(campaign)
                cat(nrow(outlier_campaigns), "outlier campaign(s) detected for trait", colnames(data_sub)[3])
                if (nrow(outlier_campaigns) >= 1){cat(":", paste(outlier_campaigns$campaign), "\n")}
                else{cat("\n")}
                return(data_sub |> filter(! campaign %in% outlier_campaigns) |>
                       group_by(campaign) |> filter(n()>1) |> ungroup())}

make_BH_multtest <- function(asreml_res){
                trait_title <- colnames(asreml_res$mf)[3] |> str_replace_all("_", " ") |> str_to_title()
                residual <- asreml_res$residuals
                MAD <- 1.4826*median(abs(residual-median(residual))) #approx constant https://en.wikipedia.org/wiki/Median_absolute_deviation#Relation_to_standard_deviation
                rawp_BHStud <- 2 * (1 - pnorm(abs(residual/MAD)))
                test_BHStud <- mt.rawp2adjp(rawp_BHStud, proc=c("Holm"))
                result_df <- tibble(adjp=test_BHStud[[1]][,1], bholm=test_BHStud[[1]][,2], index=test_BHStud[[2]]) |>
                        mutate(is_outlier = bholm < 0.05) |> arrange(index) |> mutate(std_residual = scale(residual)[,1])
                cat(sum(result_df$is_outlier), "outlier value(s) detected for trait", trait_title, "\n")
                plot(ggplot(result_df, aes(index,std_residual, color=is_outlier)) + geom_jitter()
                     + scale_colour_manual(values = c("TRUE" = "#A51D2D", "FALSE" = "#26A269"))
                     + labs(title = trait_title, subtitle = "Outlier detection with Bonferroni–Holm method"))
                return(result_df |> as.data.frame())}

correct_II <- function(data_corrected_I, result_BH){
                data_corrected_I[result_BH[which(!result_BH$is_outlier),"index"],] |> 
                group_by(accenumb) |> filter(n() > 1) |> group_by(campaign) |> filter(n() > 1) |> 
                arrange(campaign, accenumb) |> as.data.frame() |> droplevels()}

get_quality <- function(data_sub, asreml_res_h){
                trait <- colnames(data_sub)[3]
                varcomp <- summary(asreml_res_h)$varcomp
                var_G <- varcomp[2,"component"]
                var_E <- mean(varcomp[3:nrow(varcomp),"component"])
                no_campaigns <- mean(table(data_sub$accenumb[!is.na(data_sub[,trait])]))
                heritability <- var_G/(var_G+(var_E/no_campaigns))
                cat(colnames(data_sub)[3], "heritability:", round(heritability*100,1), "%\n")
                return(tibble(trait, heritability, var_G, var_E, no_campaigns))}

get_BLUEs <- function(asreml_data){
                trait <- colnames(asreml_data$mf)[3]
                intercept_index <- nrow(asreml_data$coeff$fixed)
                intercept <- asreml_data$coeff$fixed[intercept_index]
                BLUE <- asreml_data$coeff$fixed[-intercept_index,] + intercept
                return(BLUE |> as.data.frame() |>
                        rownames_to_column() |>
                        mutate(genotype=str_split_i(rowname,"_", -1)) |> #assuming there is no underscore in the accession numbers
                        select(genotype, BLUE) |> rename_with(~paste(trait, .x, sep="_"), 2))}
