
capture program drop CPIannual
program define CPIannual
preserve
	args 		year_inic base time
	
	clear
	qui set fredkey XXXXXXXXXXXXXXXXXXX,perm
	*https://fred.stlouisfed.org/series/CPIAUCSL
	local today : display %tdCYND date(c(current_date), "DMY")
	local yr_e = substr("`today'",1,4)
	local mn_e = substr("`today'",5,2) 
	qui import fred CPIAUCSL, daterange(`year_inic'-01-01 `yr_e'-`mn_e'-01) aggregate(annual,avg) long clear
	qui gen year=year(daten)
	drop series_id datestr
	qui gen factor = 1 if year==`base'
	qui sum value if factor==1
	local bs=r(mean)
	qui replace factor = `bs'/value
	keep year factor
	rename year `time'
	
	tempfile Defl
	qui save 	`Defl'
		
restore

qui merge m:1 `time' using  `Defl'	
qui keep if _merge==3
drop _merge

local k = 4
while "``k''" != ""{
    local ++k
	*di "`k'"
}
local k=`k'-1
forvalues v=4/`k'{
	qui gen ``v''_rl= factor * ``v''
	drop ``v''
	rename ``v''_rl ``v''
	
	display "The variable ``v'' is real now, base `base'"
}
end

*set trace on
*			var year_inic base time
*capture drop factor
*CPIannual 	1999 2018 year Expenses
