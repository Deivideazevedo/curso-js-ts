
DECLARE	@sql varchar(1000);
DECLARE @mar_dt_mov DATETIME = '01/11/2024';
				
declare 
	@tmp_int_registro_go table 
	(
		 id numeric(18)
		, emp_cd_codigo char(50)	not null
		, matricula char(11)		not null
		, user_id int					null
		, data datetime					null
		--, localizacao varchar(200)		null
		, codigo varchar(11)			null
		, terminal varchar(200)			null
	)	
		
set @sql = 
'
select  
   reg.id
    , emp_cd_codigo
    , matricula
    , reg.user_id
    , date_format( data, "%d/%m/%Y %H:%i" ) as data			    
    , reg.codigo
    , ter.nome as terminal
from 
	registros reg
left join 
	terminais ter
		on reg.emp_cd_codigo = ter.emp_cd_empresa
		and reg.codigo = ter.codigo
where emp_cd_codigo = 11
and date_format(data, "%Y-%m-%d %H:%i") >  date_format(date_add("' + convert (varchar (19), @mar_dt_mov, 20) + '", interval 0 day), "%Y-%m-%d %H:%i") 
and date_format(data, "%Y-%m-%d %H:%i") <= date_format(date_add("' + convert (varchar (19), @mar_dt_mov, 20) + '", interval 2200 minute), "%Y-%m-%d %H:%i") 
order by emp_cd_codigo, matricula, data asc
'	
			
insert into @tmp_int_registro_go (id,emp_cd_codigo,matricula,user_id,data,codigo,terminal)
execute(@sql) at mysql_folha


--MOTORISTA
;WITH cte_operadores AS (

	SELECT 
	   mar.fnc_cd_funcionario, 
	   crg.crg_nm_cargo,
	   esc.esc_cd_linha, 
	   mar.mar_dt_mov,
	   mar.mar_dt_marcacao,
	   CONCAT('G',fnc.fnc_cd_garagem) AS fnc_cd_garagem,
	   esc.esc_hr_inicio,
	   esc.esc_hr_fim,	   
	   row_number() OVER (PARTITION BY mar.fnc_cd_empresa, mar.fnc_cd_funcionario ORDER BY mar.mar_dt_marcacao) AS row 
	FROM mar_marcacao mar WITH (nolock)
	LEFT JOIN res_reserva res WITH (nolock)
	    ON res.res_cd_empresa = mar.fnc_cd_empresa
	    AND res.res_cd_motorista = mar.fnc_cd_funcionario
	    AND res.res_dt_inicio  <= @mar_dt_mov 
	    AND (res.res_dt_final  >= @mar_dt_mov OR res.res_dt_final IS NULL)
	LEFT JOIN esc_escala esc WITH (nolock)
	    ON esc.esc_cd_empresa = mar.fnc_cd_empresa
	    AND esc.esc_cd_motorista = mar.fnc_cd_funcionario
	    AND esc.esc_dt_escala =  mar.mar_dt_mov
	LEFT JOIN fnc_funcionario fnc WITH (nolock)
	    ON fnc.fnc_cd_empresa = mar.fnc_cd_empresa
	    AND fnc.fnc_cd_funcionario = mar.fnc_cd_funcionario
	LEFT JOIN crg_cargo crg WITH (nolock)
	    ON fnc.fnc_cd_cargo = crg.crg_cd_cargo
	WHERE
		mar.fnc_cd_empresa = 10
	    AND mar.mar_dt_mov = @mar_dt_mov
	    AND (esc.esc_cd_linha NOT LIKE 'RES%' OR esc.esc_cd_linha IS NULL)
	    AND crg.crg_tp_cargo = 'M'
	    AND res.res_cd_motorista IS NULL
	    AND fnc.fnc_cd_garagem NOT IN (9,6,7)
	 
	UNION ALL
	
	SELECT
	   mar.fnc_cd_funcionario, 
	   crg.crg_nm_cargo,
	   esc.esc_cd_linha, 
	   mar.mar_dt_mov,
	   mar.mar_dt_marcacao,
	   CONCAT('G',fnc.fnc_cd_garagem) AS fnc_cd_garagem,
	   esc.esc_hr_inicio,
	   esc.esc_hr_fim,	   
	   row_number() OVER (PARTITION BY mar.fnc_cd_empresa, mar.fnc_cd_funcionario ORDER BY mar.mar_dt_marcacao) AS row 
	FROM mar_marcacao mar WITH (nolock)
	LEFT JOIN res_reserva res WITH (nolock)
	    ON res.res_cd_empresa = mar.fnc_cd_empresa
	    AND res.res_cd_cobrador = mar.fnc_cd_funcionario
	    AND res.res_dt_inicio  <= @mar_dt_mov 
	    AND (res.res_dt_final  >= @mar_dt_mov OR res.res_dt_final IS NULL)
	LEFT JOIN esc_escala esc WITH (nolock)
	    ON esc.esc_cd_empresa = mar.fnc_cd_empresa
	    AND esc.esc_cd_cobrador = mar.fnc_cd_funcionario
	    AND esc.esc_cd_cobrador IS NOT NULL 
	    AND esc.esc_dt_escala =  mar.mar_dt_mov
	LEFT JOIN fnc_funcionario fnc WITH (nolock)
	    ON fnc.fnc_cd_empresa = mar.fnc_cd_empresa
	    AND fnc.fnc_cd_funcionario = mar.fnc_cd_funcionario
	LEFT JOIN crg_cargo crg WITH (nolock)
	    ON fnc.fnc_cd_cargo = crg.crg_cd_cargo
	WHERE
		mar.fnc_cd_empresa = 10
	    AND mar.mar_dt_mov = @mar_dt_mov
	    AND (esc.esc_cd_linha NOT LIKE 'RES%' OR esc.esc_cd_linha IS NULL) 
	    AND crg.crg_tp_cargo = 'C'
	    AND res.res_cd_cobrador IS NULL
	    AND fnc.fnc_cd_garagem NOT IN (9,6,7)
	    
),
cte_qrcode AS (
	SELECT 
		id, emp_cd_codigo, CAST(matricula AS INT) AS matricula, user_id, data, codigo, terminal, ROW_NUMBER() OVER (PARTITION BY emp_cd_codigo, matricula ORDER BY data) AS row 
	FROM @tmp_int_registro_go
)
SELECT 
	ISNULL(fnc_cd_funcionario,'') AS matricula,
	ISNULL(crg_nm_cargo,'') AS cargo,
	ISNULL(fnc_cd_garagem,'') AS garagem, 
	CASE WHEN mar_dt_marcacao IS NULL THEN '' ELSE convert(VARCHAR(10),mar_dt_marcacao,103) +' '+ convert(VARCHAR(8),mar_dt_marcacao,108) END AS batida,
	ISNULL(terminal,'') AS terminal, 
	ISNULL(esc_cd_linha,'') AS linha, 
	CASE WHEN esc_hr_inicio IS NULL THEN '' ELSE CONVERT(VARCHAR(20), esc_hr_inicio, 108) END AS esc_hr_inicio,
	CASE WHEN esc_hr_fim IS NULL THEN '' ELSE CONVERT(VARCHAR(20), esc_hr_fim, 108) END AS esc_hr_fim
FROM cte_operadores
LEFT JOIN cte_qrcode
	ON cte_qrcode.matricula = cte_operadores.fnc_cd_funcionario
WHERE 
	cte_operadores.row = 1
	AND cte_qrcode.row = 1