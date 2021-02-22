
- Folder `auc_results_6_models_400_params` contains AUC of 6 models with 400 different hyperparameter settings for each model.
Each file corresponds to one data set from the OpenML database. To inspect a data set, paste `https://www.openml.org/d/XXX` into the browser, where XXX is the number of the data set. For example `https://www.openml.org/d/3` for `3.csv`.


- Folder `elo_results_6_models_400_params` contains Elo scores of 6 models with 400 different hyperparameter settings for each model. Elo is calculated on the basis of AUC values from models in `auc_results_6_models_400_params`.


- `compare_sport_elo.R` is a script that computes elo with the sport package and compares it with the Elo calculated with [EloML](https://github.com/ModelOriented/EloML).


- Folder `data` contains saved partial results from the script `compare_sport_elo.R`.

In Elo terms, model with defined set of hyperparameters is a player, train/test cross-validation splits are matches.