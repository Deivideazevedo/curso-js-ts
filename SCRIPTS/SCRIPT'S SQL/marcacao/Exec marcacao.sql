EXEC sp_sdo_rlt_frq_mar_jovem  10,'09/02/2024', '11/02/2024', 343, 'w_rlt_tab_fnc_bairro'
EXEC sp_sdo_rlt_frq_mar_jovem_sub 10,'12/09/2024', '13/09/2024', 3826
EXEC sp_sdo_rlt_frq_mar_jovem_sub 

SELECT * FROM tmp_sel_funcionario
WHERE janela = 'w_rlt_tab_fnc_bairro'

SELECT TOP 1000 * FROM mar_marcacao

WHERE
fnc_cd_funcionario = 3826 
ORDER BY mar_dt_mov DESC

'09/02/2024 00:00:00'
'11/02/2024 00:00:00'
AND mar_dt_mov >= '12/09/2024'
AND mar_dt_mov <= '13/09/2024' 

SELECT * FROM bdo_bh_operador
WHERE 

2045,9,1107,1586,539,2262,8050