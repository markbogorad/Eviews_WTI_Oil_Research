'Preliminary Steps:'

	'Renaming each series to make it easier to use'

series wti=rwtc_cushing__ok_wti_spot_price_fob__dollars_per_barrel_

series brent=rbrte_europe_brent_spot_price_fob__dollars_per_barrel_

series gulfgas=eer_epmru_pf4_rgc_dpg_u_s__gulf_coast_conventional_gasoline_regular_spot_price_fob__dollars_per_gallon_

series gulfdiesel=eer_epd2dxl0_pf4_rgc_dpg_u_s__gulf_coast_ultra_low_sulfur_no_2_diesel_spot_price__dollars_per_gallon_

series nygas=data_2__conventional_gasoline_eer_epmru_pf4_y35ny_dpg_new_york_harbor_conventional_gasoline_regular_spot_price_fob__dollars_per_gallon_

series nydiesel=data_5__ultra_low_sulfur_no__2_diesel_fuel_eer_epd2dxl0_pf4_y35ny_dpg_new_york_harbor_ultra_low_sulfur_no_2_diesel_spot_price__dollars_per_gallon_

series ladiesel=eer_epd2dc_pf4_y05la_dpg_los_angeles__ca_ultra_low_sulfur_carb_diesel_spot_price__dollars_per_gallon_

series hoil=data_4__no__2_heating_oil_eer_epd2f_pf4_y35ny_dpg_new_york_harbor_no__2_heating_oil_spot_price_fob__dollars_per_gallon_

series jfuel=data_6__kerosene_type_jet_fuel_eer_epjk_pf4_rgc_dpg_u_s__gulf_coast_kerosene_type_jet_fuel_spot_price_fob__dollars_per_gallon_

series rbob=data_3__rbob_regular_gasoline_eer_epmrr_pf4_y05la_dpg_los_angeles_reformulated_rbob_regular_gasoline_spot_price__dollars_per_gallon_

series propane=data_7__propane_eer_epllpa_pf4_y44mb_dpg_mont_belvieu__tx_propane_spot_price_fob__dollars_per_gallon_

	'I noticed in prior attempts that regime switching models and GARCH models would not work with an irregular series. I decided to drop all the NA variables in my series in order to be able to estimate these models'
 
	'Dropping all NA variables in each series'
	pagecontract if brent and wti and gulfgas and gulfdiesel and hoil and jfuel and ladiesel and nydiesel and nygas and propane and rbob<>NA

'Variable of Interest: WTI'

'Testing for Non-Stationairty & The Presence of a Unit Root'
	'My first step with this data was to check WTI for a unit root with a breakpoint unit root test with trend and breaks in the alternative. The resulting p-value for this test was 0.283, therefore highlighting the unit root problem. I confirmed this result with a standard unit root test using the ADF test with the Schwarz criterion (since I have 648 observation). This reaffirmed the results of the breakpoint unit root test with a p-value of 0.284'

	'I then did this same process for each exogenous variable, finding a unit root in each series. My conclusion from this was to work with the differences (y-(y-1)) of all of these variables. I did this as follows:'

	'each series differenced'
		series gulfdieseld=d(gulfdiesel)
		series gulfgasd=d(gulfgas)
		series hoild=d(hoil)
		series jfueld=d(jfuel)
		series ladieseld=d(ladiesel)
		series nydieseld=d(nydiesel)
		series nygasd=d(nygas)
		series propaned=d(propane)
		series rbobd=d(rbob)
		series brentd=d(brent)
		series wtid=d(wti)

	'I then tested for 2nd order unit roots in each variable by using the same 2 tests as before but on the returns of each series. I fortunately found no instances of 2nd order unit roots. I also tested for the presence of a trend in WTI to ensure I am not working with a deterministic trend process. I did this by regressing @trend on WTID and checking it's significance. I found it to be non-signifcant, confirming that I have no trend in the data. I decided to proceed working with the differences.'

	'I decided to not work with the log differences because the unit root issue was fixed with just the differences and taking the log differences of WTI would cause a break in the code due to an error message about missing data being generated for a log of a non-positive observation in WTI. The interpretation of the differences would be the spot price amount change in the spot price of WTI day-to-day (instead of the percentage change in the price day-to-day as with log differences). Therefore, I will be forecasting the amount that the spot price will change day-to-day in levels'

'Testing The Data for Breaks'

	'I tested the full sample for breaks using a breakls equation with all of the exogenous variables to locate the specific break dates, finding several breaks in the data, most importantly the latest one on 4/21/2020 due to the COVID pandemic'

	'My approach to deal with the break on 4/21/2020 was to disregard all observations corresponding with this break and prior, estimating my in-sample period after the break. I noticed that the increased bounds of the WTI data after the break returned to previous levels on 5/06/2020, so I estimated from this date. This left me with 648 total observations, which is more than plenty to do a 15 and 20 day rolling window forecast considering a 2:3 in-sample to out of sample ratio is the general rule of thumb.'

	'Contracting workfile to data only after the break
	pagecontract 5/06/2020 12/27/2022
	
		'I tested for breaks within the smaller sample using the same method again and found one on 7/29/2022. I decided to not cut the sample again for 2 reasons. Firstly, in the context of the larger, first in-sample period (from 2002), this break would not have been picked up as seen in the first test. Second, cutting from this date would leave me with 100 observations, which will likely impact my ability to generate robust models to forecast the mean (assuming I don't find breaks in the 100 observation sample and cut even further and decrease the richness of the forecast even more). Since there is some rationale for the break on 7/29/2022, as this was a period when the prolonged war in Ukraine was shaking up oil prices, work in the future can be enhanced by replicating the data post 7/29/2022 and merging it with the remaining data after the break to have a larger amount of observations to run various models. This would also be useful in capturing the noticable increased range of price changes post 7/29/2022.'

'Mean Candidate Model Selection'

	'ARMA Models'
		'In my testing for ARMA models, I found the best model to be an AR(3) with brentd, gulfgasd, gulfdieseld, nygasd, jfueld, jfueld(-1) and propaned. I decided this model was the best ARMA model to forecast WTID because this was the maximum order of ARMA components that was signficant (no MA componets were significant), and the maximum number of significant exogenous variables, all at the 5% level. I also found significance in a lagged value of jfueld when estimating an ARDL model on all of the regressors. The AR(3) component had a p-value in the T test of 0.0365, so if my sample is too short or I am overparamaterized, I will look to cut higher order AR components to make it more parsimonious or cut out jfueld(-1) since I am also accounting for the variable's effect with jfueld. Moreover, it is important to note the significance of the AR component up to lag 3 suggests the series has no linear dependance with itself up to 3 lags. I will consider this as an important factor to incorporate when estimating other models for the mean'
		equation ar3.ls wtid c brentd gulfgasd gulfdieseld nygasd jfueld jfueld(-1) propaned ar(1) ar(2) ar(3)
	
	'Markov Switching Models"
		'While in the origional sample (from 2002) it did not appear to me that there is a sign of a regime switch (graphically), it is important to test this assumption in this smaller sample after the COVID break, since there could be smaller-scale regime switches within this subset. My approach to finding a suitable Markov switching model consisted of testing different signifcant regressors in search for significant transition matrix parameters at the 5% level. This required cutting several previously significant variables in order to preserve a singificant transition matrix. 
	'In this trade-off between having more signficant variables and having a singificant transition matrix, the best Markov switching model I derived was an MSAR with 2 regimes, having brentd as a regime switching regressor and C, gulfgasd, AR(1), and AR(2) as non-switching. The transition matrix was just under the 5% level with a value of 0.0454 for regime 1 and 0 for regime 2. 
	equation mkov.switchreg(type=markov, seed=1755733011) wtid brentd @nv c gulfgasd ar(1) ar(2) @prv c

	'Threshold Autoregressive Models'
		'To test whether or not the series has a regime switch that is exogenously driven, I also tested 2 TAR models; a SETAR and a TAR with a delay parameter of 5. I did not estimate STAR models because I believe a smoothed transition is not a valid specification for this data, since smoothed transitions are used for macro factors and longer term data. Moreover, in the several attempts I made, I failed to find a combination of variables leading to a significant threshold variable, further suggesting the STAR is not a good specification.'

		'The best possible SETAR I derived had c, brentd, propaned, nygasd, and ladieseld as threshold varying variables and no variables as non-varying since the rest were not significant as varying or non-varying in any regime. I decided these 5 variables were important to inlcude because each is significant in at least one regime. It is important to note that a lagged value of WTI was not signifcant in this model, meaning that this model might not account for serial correlation. To examine whether this is the proper specification, I will see it's forecasting perfomance since there is no "threshold" variable in the SETAR and ensure it passes the post estimation diagnostic tests.'
	equation setar.threshold wtid c brentd propaned nygasd ladieseld @thresh wtid

		'I derived the best TAR model by having a threshold specification of up to 6 lags to the previous significant variables in the SETAR and adding hoild, gulfdieseld, and gulfgasd to the equation as I found these to be significant under the new specification. Adding a lagged value of WTID in this case also proved successful as it was signifcant, so this model does capture a degree of linear dependance. The Bruce Hansen methodology select WTID(-5) as the delay parameter. To confirm that this model is a good specification I will check it's forecasting perfomance the same way as the SETAR. I will denote this model as TAR5'
	equation tar5.threshold wtid c brentd propaned nygasd ladieseld hoild @thresh 2 6

	'Testing Candidate's Forecasting Perfomance'
		'To decide which model among these candidates would be the best in out of sample forecasting perfomance, I forecasted the last 15 trading days (12/07/2022 12/27/2022) in each model. Then, I conducted a Diebold Mariano test using the last 15 trading days as the evaluation sample and the full period in-sample as the training sample. I found the best model out of the candidates to be the SETAR, having the lowest values in all of the loss functions except the MAPE, but, most importantly, the lowest MSE. However, the TAR5 came in 2nd place in all loss functions apart from the MAPE and it accounts for linear dependance with the WTI(-1) extra factor. I will check whether the SETAR has linear dependance in my post estimation diagnostic tests, and choose either the SETAR or TAR5 on the results of the tests and forecasting perfomance.'

'Model Selection Based on Forecasting Perfomance and Post Estimation Diagnostic Tests:'
	
'Post Estimation Diagnostic Tests for The SETAR'
	'Testing for Linear Dependance with the Ljung-Box test (correlogram)'

		setar.correl
		'It is evident from the p-values of the Ljung-Box test that the null hypothesis (no serial correlation) can't be rejected for all of the lags. Therefore implying that there is no serial correlation in the model. This is a good sign for the SETAR, implying that it accounts for serial correlation without a lagged value of WTID.

	'Testing for Non-Linear Dependance with the Squared Correlogram'
		
		setar.correlsq
		'The squared correlogram also shows no signficance at all lags. This means that there is also no non-linear dependance in the model; another good sign for the SETAR.'

	'Testing For the Presence of Heteroskedasticity'
		
		setar.archtest(lags=5)
		'The ARCH LM test . I used 5 lags for this test to capture a week of daily data. The result is a very high p-value (0.8866), therefore implying there is no heteroskedasticity in the SETAR.

		setar.hettest @vary(c) @vary(brentd) @vary(propaned) @vary(nygasd) @vary(ladieseld)
		'I double checked for the presence of heteroskedasticity with the Bresuch-Godfrey test, validating the result of no heteroskedasticity in the SETAR.'

'Final Choice: SETAR'
	'I have decided to use the SETAR since it is the best in forecasting perfomance for the 15-day horizon and passes all of the post-estimation diagnostic tests. From the stationairty implied by the prior unit root tests, it can be inferred that the variables in this model do not display signs of a random walk since there is no unit root or trend. There is also no instance of spurious regression since there are no unit roots at all. The SETAR is the clear winner in all aspects. I will proceed to take the SETAR through the 15-day rolling window and compare it with the ETS smoothed benchmark, which is the relevant benchmark for regime switching models.'

'15-Day Rolling Window Forecast:'

!window=45 'Setting the total window size. This corresponds to the out of sample period of 15 days + the in sample period (30 days to have a 2:3 ratio with out of sample) for a total of 45 '

!length=@obsrange 'defining the length of the rolling window (the full sample) as the range'

!step=1 'step size, corresponding to 1 day'

!j=0 'j is the variable to keep track of the amount of rolls'

series setarfcast 'creating a series to store rolling forecast'

'generating a wti smoothed benchmark for the SETAR using ETS'
	wtid.ets(smpl="5/06/2020 12/06/2022", forc="12/27/2022") wtid_etssm

'defining start and end points of the full sample as strings'
%start = "@first" 'string called start corresponding to first observation (5/6/2020)'
%end = "@last" 'string called end corresponding to last observation (12/27/2022)

for !i=1 to !length-!window+1-!step step !step 'move the sample "step" at a time where 1 step is equal to 1 for 1 day'
!j=!j+1

'full sample period'
%first=@otod(@dtoo(%start)+!j-1)
%last=@otod(@dtoo(%start)+!i+!window-2)
smpl {%first} {%last}

equation setar.threshold wtid c brentd propaned nygasd ladieseld @thresh wtid 'estimating SETAR equation again for rolling'

%15pers=@otod(@dtoo(%start)+!i+!window-1) 'out of sample dropping first observation at the start'
%15pere=@otod(@dtoo(%start)+!i+!window+14) 'out of sample adding newest forecasted observations'

smpl {%15pers} {%15pere} 'setting the sample for out of sample period'

setar.forecast(f=na) setarf 'forecasting with the model to create forecasted series called setarf'

setarfcast=setarf 'storing forecasts in previously created series called setarforecast'

smpl @all 'restoring whole sample'

'loss functions for forecasting comparison:'

scalar mnmse=@mse(wtid, setarfcast) 'mean squared error'
scalar mnmae=@mae(wtid, setarfcast) 'mean absolute error'
scalar mnrmse=@rmse(wtid, setarfcast) 'root mean squared error'
scalar mnmape=@mape(wtid, setarfcast) 'mean absolute percentage error'
scalar mnsmape=@smape(wtid, setarfcast) 'symmetric mean absolute percentage error'
scalar mntheil=@theil(wtid, setarfcast)  'theil inequality coefficient '

'same loss functions but for the ets smoothed benchmark'
scalar etsmse=@mse(wtid, wtid_etssm) 
scalar etsmae=@mae(wtid, wtid_etssm) 
scalar etsrmse=@rmse(wtid, wtid_etssm)
scalar etsmape=@mape(wtid, wtid_etssm) 
scalar etssmape=@smape(wtid, wtid_etssm) 
scalar etstheil=@theil(wtid, wtid_etssm) 

next

'I will analyze the results of the SETAR's rolling perfomance in the end in one table together with volatility'


'Key Preliminary Decision on the Volatility Models:

		'I have decided to model the volatility of the differences in my dependent variable (WTI) rather than the traditional method of modelling the log differences (returns) of the dependent variable. I chose this for several reasons. Firstly, and most importantly, taking the log of each of the variables would cut out every negative observation in each series, creating more NA variables for each negative observation. This would cut out a lot of data, decreasing the accuracy of my models, as well as completely ignoring the asymmetry component (leverage effect), rendering the GJR model useless. I considered accounting for the lost values but losing the asymmetry component by taking the absolute value of each series (abs command) and then taking the log of each series in asbolute terms. However, leading into my second reason for using differences, taking the log of each series in absolute terms would still cause a break in the code. When coupled with the fact that asymmetry would not be recognized, the clear choice was to model the differences. It is important to note that the interpretation for these models is the volatility of the level of returns, not the volatility of the percentage change in returns.'

'Preliminary Models & Post-Estimation Testing for The Volatility of WTID'

	'My first step in modelling volatility is to estimate a preliminary GARCH(1,1) with all possible significant regressors in the mean equation using the 5% significance level. From this I will use GARCH add ons to account for asymmetry and/or long memory if found. I will also use this GARCH(1,1) as a benchmark for my final model in rolling window forecasting. I will use the OPG-BHH optimization method for all my volatility models, as it is superior than BFGS, which is better for mean modelling'

	'Preliminary GARCH(1,1) model:'
	equation eqgarch11.arch(tdist, optmethod=opg) wtid c 

		'Though Brentd, Propaned, Nydieseld, Nygasd, and Gulfgasd were signficant in the mean equation, their presence violated the condition of stationarity for volatility (coefficients of Alpha + Beta < 1) and had to be dropped to ensure stationairty. Moreover, the sum of the Alpha and Beta coefficients is 0.998601, suggesting a very strong presence of long memory, which I will test for properly in the coming models' 

	'Test for GARCH in mean effect'
	equation garchinmean.arch(tdist, archm=var, optmethod=opg) wtid c

		'To see a GARCH in mean effect, I examine the "GARCH" variable's p-value. The resulting p-value is insigificant at 0.7318. This implies that it is not true that increasing volatility will impact the expected value WTID, i.e., there is no garch in mean effect.'

	'Test for leverage effect (sign-bias test)'
	eqgarch11.signbias
		
		'The sign-bias test points towards no rejection of the null of no asymmetry with a p-value of 0.16 under the Joint-Bias statistic. This suggests the model has no asymmetry, therefore, estimating a GJR model will likely not enhance perfomance.'
	
	'Test for Long Memory Using FIGARCH D Parameter'
	equation figarch.arch(tdist, figarch, optmethod=opg) wtid c
	
		'To see if the series displays long memory, I examined the p-value of the D parameter, which accounts for long memory. It is significant at the 1% level, confirming the presence of long memory. Moreover, the coefficient of the D paramater is 0.475958, very close to the maximum allowable amount for this coefficient of 0.5. This means this series has a very strong presence of long memory. This is likely the reason why adding variables in the mean equation affected stationairity.'

	'Now that I have confirmed long memory in the series, I would like to test if there is a presence of asymmetry together with long memory, though I doubt asymmetry will be present due to the results of the Sign-Bias test. I have built on the FIGARCH to code a model that accounts for both asymmetry with the Gamma parameter as seen in the GJR and long memory with the D parameter as seen in the FIGARCH'

		series asymmetry = resid(-1)^2 + resid(-1)^2*(resid(-1)<0)
			'series capturing Gamma parameter (the additonal shock coming from negative returns + the normal shock coming from positive returns) just like in the DJR. These residuals are coming from the mean equation of the FIGARCH estimated previously, so it is the same as the mean equation of this model.'

		equation asymmetricfigarch.arch(tdist, figarch, optmethod=opg) wtid c @ asymmetry		
		'Adding asymmetry series to the previous FIGARCH equation'

	'From the output of this equation, it is evident that asymmetry is still not significant by the p-value of t test of C(5), which is the factor capturing asymmetry. I will proceed with FIGARCH-X models to find the best model.'

	'Adding Brent as a variance regressor to previous FIGARCH'
	equation figarchx.arch(tdist, optmethod=opg) wtid c @ brentd
	
	'I successfully added Brentd as a variance regressor. This was the only regressor I could add to the variance with the all additonal regressors being significant and the condition for stationarity being preserved. 

'Additonal Post-Estimation Diagnostic Tests on the FIGARCHX'

	'Linear Dependance
		figarchx.correl
			'Using the same logic for this test as I did in the mean estimation, it can be inferred that there is no serial correlation for all lags.'

	'Non-Linear Dependance'
		figarchx.correl
			'No sign of non-linear dependance as well, though there is almost significance at the 2nd lag for the 5% level with a p-value of 0.054. At this point, the model is passing.'

	'Heteroskedasticity'
		figarchx.archtest(lags=5)
			'No heteroskedasticity found using same test & logic as before.'

	'Breaks in the Volatility'
		figarchx.nyblom
			'The Nyblom stability test is a test on parameter stability, in other words a structural change in the model. The joint test statistic of the Nyblom stability test must be greater than the given % significance levels to justify a structural break. Here it is evident that the joint test statistic is lower at all levels, confirming that there is no structural break in the volatility.'

'Final Choice: FIGARCHX with Brentd'
	'I have chosen the FIGARCHX as my strongest model on the basis of it passing all the post estimation diagnostic tests and it including long memory as well as a signficant variable in the variance equation. I believe this is the most robust specification for the WTID data while maintaining stationarity. At this stage I see no point in doing a Diebold-Mariano test on the rest of the models, as they either fail to account for long memory or account for asymmetry pointlessly (it was seen to not be signifcant). The remaining models are the FIGARCH without an additonal significant factor (Brentd) in the mean, which is less robust than the FIGARCHX, and the GARCH(1,1), which will be the benchmark for comparison.

'20 Day Rolling Window for Volatility'
	
	'Generating a proxy for realized volatility to compare with in rolling;
		equation mnequation.ls wtid c
		series volproxy=resid^2
		
'I will preform the same exact rolling code as the mean except edited for 20 day horizon. I will also take both the FIGARCHX and the GARCH(1,1) through the rolling window so I can compare both forecasts under the same method'

!window=60 'new window, same principles'
!length=@obsrange
!step=1

equation figarchx 'creating equation for FIGARCHX with Brentd'
equation eqgarch11 'creating an equation for GARCH(1,1)

!j=0

'creating a series for both forecasts out of the rolling window'
series figarchxfcast
series garchfcast

'same specifications for the sample as before:'
%start="@first"
%end="@last"

for !i=1 to !length-!window+1-!step step !step 
!j=!j+1
%first=@otod(@dtoo(%start)+!j-1)
%last=@otod(@dtoo(%start)+!i+!window-2)
smpl {%first} {%last}

equation figarchx.arch(tdist, optmethod=opg) wtid c @ brentd 'equation for FIGARCHX'

equation eqgarch11.arch(tdist, optmethod=opg) wtid c 'equation for GARCH(1,1)

'New 20-period sample start and end'
%20pers=@otod(@dtoo(%start)+!i+!window-1)
%20pere=@otod(@dtoo(%start)+!i+!window+19) '5 days added to previous period ending'

smpl {%20pers} {%20pere}

figarchx.forecast(f=na) yf 'forecasting from FIGARCHX and calling the forecasted series yf'
figarchxfcast=yf 'setting yf equal to the series made to catch the forecast'

eqgarch11.forecast(f=na) gf 'forecasting from GARCH(1,1) and calling the series gf'
garchfcast=gf 'setting gf equal to the series made to catch the forecast'

smpl @all 

'Generating same loss functions using squared residuals of the mean equation as a proxy for the observed volatility'
scalar volmse=@mse(volproxy, figarchxfcast) 
scalar volmae=@mae(volproxy, figarchxfcast) 
scalar volrmse=@rmse(volproxy, figarchxfcast)
scalar volmape=@mape(volproxy, figarchxfcast) 
scalar volsmape=@smape(volproxy, figarchxfcast) 
scalar voltheil=@theil(volproxy, figarchxfcast) 

'Generating loss functions for the benchmark'
scalar garchmse=@mse(volproxy, garchfcast) 
scalar garchmae=@mae(volproxy, garchfcast) 
scalar garchrmse=@rmse(volproxy, garchfcast)
scalar garchmape=@mape(volproxy, garchfcast) 
scalar garchsmape=@smape(volproxy, garchfcast) 
scalar garchtheil=@theil(volproxy, garchfcast) 

next

'Table to capture results of winning models with respect to their benchmarks'

'Final Results'
table results 
results (1,1) = "Model"
	results (3,1) = "SETAR"
	results (4,1) = "ETS Benchmark"
	results (6,1) = "FIGARCHX with Brent"
	results (7,1) = "GARCH (1,1) Benchmark"
results (1,3) = "MSE"
	results (3,3)= mnmse
	results (4,3)= etsmse
	results (6,3) = volmse
	results (7,3) = garchmse
results (1,4) = "MAE"
	results (3,4)= mnmae
	results (4,4)= etsmae
	results (6,4) = volmae
	results (7,4) = garchmae
results (1,5) = "RMSE"
	results (3,5)= mnrmse
	results (4,5)= etsrmse
	results (6,5) = volrmse
	results (7,5) = garchrmse
results (1,6) = "MAPE"
	results (3,6)= mnmape
	results (4,6)= etsmape
	results (6,6) = volmape
	results (7,6) = garchmape
results (1,7) = "SMAPE"
	results (3,7)= mnsmape
	results (4,7)= etssmape
	results (6,7) = volsmape
	results (7,7) = garchsmape
results (1,8) = "THEIL"
	results (3,8)= mntheil
	results (4,8)= etstheil
	results (6,8) = voltheil
	results (7,8) = garchtheil

results.table


	'Mean Results'

	'The mean results show that the SETAR is beating the ETS smoothed benchmark in all of the loss functions by far. Along with passing all the post estimation diagnostic tests and proving it's dominance to the candidates in the Diebold-Mariano test, the SETAR is the clear winner for the mean.'

	'Volatility Results'

	'The FIGARCHX with Brentd in the variance equation is beating the GARCH(1,1) benchmark in all of the loss functions as well, though by not that great of a margin as seen with the SETAR and ETS for example. This is likely because the GARCH(1,1) is a much stronger benchmark for volatility than the ETS is for the mean, therefore higher perfomance of the GARCH relative to the FIGARCHX is expected. Moreover, when considering the fact that the FIGARCHX is accounting for the presence of long memory, which is very strong in WTID, it becomes the clear winner.'

	'Future work can be enhanced in many ways. Adding intra-daily data, for example, hourly observations of the S&P energy index, and using the MIDAS technique could enhance modelling for both the mean (ex: Markov Switching MIDAS) and the volatility (GARCH-MIDAS). Merging a similar subset of the data post the break with the current availible data could also prove beneficial in providing a larger sample to work with.'

	'Thank you'
