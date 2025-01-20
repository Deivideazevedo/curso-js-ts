CREATE PROCEDURE [dbo].[sp_sdo_env_alerta_qrcode_fora_da_reserva]
   @mar_dt_mov DATETIME
AS
SET NOCOUNT ON;

DECLARE @HTML VARCHAR(MAX);  
DECLARE @titulo VARCHAR(100);
DECLARE	@sql varchar(1000);
DECLARE @var_table TABLE 
(
	matricula INT
	, cargo VARCHAR (40)
	, garagem VARCHAR (5)
	, batida DATETIME
	, terminal VARCHAR(200)
	, linha CHAR (6)
	, esc_hr_inicio DATETIME
	, esc_hr_fim DATETIME
);


				
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
INSERT INTO @var_Table 
SELECT 
	ISNULL(fnc_cd_funcionario,'') AS matricula,
	ISNULL(crg_nm_cargo,'') AS cargo,
	ISNULL(fnc_cd_garagem,'') AS garagem, 
	mar_dt_marcacao AS batida,
	ISNULL(terminal,'') AS terminal, 
	ISNULL(esc_cd_linha,'') AS linha, 
	esc_hr_inicio,
	esc_hr_fim
	
FROM cte_operadores
LEFT JOIN cte_qrcode
	ON cte_qrcode.matricula = cte_operadores.fnc_cd_funcionario
WHERE 
	cte_operadores.row = 1
	AND cte_qrcode.row = 1

/*
SET @HTML = '
<style>
    table tr td:nth-child(4),
    table tr td:nth-child(7),
    table tr td:nth-child(8){ 
      text-align: center;
    }
</style>
<table class="text-center" border="1">
    <tr>
    	<th class="text-center">Matricula</span></th>
    	<th class="text-center">Cargo</span></th>
    	<th class="text-center">Garagem</span></th>
    	<th class="text-center">Batida</span></th>
    	<th class="text-center">Local</span></th>
    	<th class="text-center">Linha</span></th>
    	<th class="text-center">Inicio Escala</span></th>
    	<th class="text-center">Fim Escala</span></th>
    </tr>'+ 
    CAST (
    (
    	SELECT 
        	td = ltrim(rtrim(matricula)), '', 
        	td = ltrim(rtrim(cargo)), '', 
            td = ltrim(rtrim(garagem)) , '', 
			td = ltrim(rtrim(iif(batida IS NULL,'', convert(VARCHAR(30),batida,103) +' '+ convert(VARCHAR(30),batida,108))  )), '',
            td = ltrim(rtrim(terminal)) , '', 
            td = ltrim(rtrim(linha)) , '', 
			td = ltrim(rtrim(iif(esc_hr_inicio IS NULL, '', CONVERT(VARCHAR(30),esc_hr_inicio,108)) )), '',
			td = ltrim(rtrim(iif(esc_hr_fim IS NULL, '', CONVERT(VARCHAR(30),esc_hr_fim,108)) )), ''
FROM @var_table	
   FOR XML PATH('tr'), TYPE
    ) AS NVARCHAR(MAX) ) + '
</table>';
*/

SET @HTML = '
<table class="text-center" border="1">
    <tr>
        <th class="text-center">Matrícula</th>
        <th class="text-center">Cargo</th>
        <th class="text-center">Garagem</th>
        <th class="text-center">Batida</th>
        <th class="text-center">Local</th>
        <th class="text-center">Linha</th>
        <th class="text-center">Ini Escala</th>
        <th class="text-center">Fim Escala</th>
    </tr>' + 
    CAST (
    (
        SELECT 
            '<td>' + ltrim(rtrim(matricula)) + '</td>', 
            '<td>' + ltrim(rtrim(cargo)) + '</td>',
            '<td align="center">' + ltrim(rtrim(garagem)) + '</td>',
            '<td style="text-align: center;">' + ltrim(rtrim(iif(batida IS NULL,'', convert(VARCHAR(30),batida,103) +' '+ convert(VARCHAR(30),batida,108)))) + '</td>', 
            '<td> ' + ltrim(rtrim(terminal)) + ' </td>', 
            '<td align="center">' + ltrim(rtrim(linha)) + '</td>',
            '<td style="text-align: center;">' + ltrim(rtrim(iif(esc_hr_inicio IS NULL, '', CONVERT(VARCHAR(5),esc_hr_inicio,108)))) + '</td>',
            '<td align="center">' + ltrim(rtrim(iif(esc_hr_fim IS NULL, '', CONVERT(VARCHAR(5),esc_hr_fim,108)))) + '</td>'
        FROM @var_Table    
        FOR XML PATH('tr'), TYPE
    ) AS NVARCHAR(MAX) ) + '
</table>';


-- CORRIGIR CONVERSÃO DO NVARCHAR
SET @HTML = REPLACE(@HTML, '&lt;', '<');
SET @HTML = REPLACE(@HTML, '&gt;', '>');

SET @titulo = 'Aviso: Batida Fora da Reserva (QRCODE) - '+ convert(VARCHAR(10),@mar_dt_mov,103)

IF (SELECT isnull(count(*),0) FROM @var_table ) > 0
	BEGIN	
		-- Envia o e-mail
		EXEC msdb.dbo.sp_send_dbmail
	    @profile_name = 'GmailProfile', -- sysname
	    @recipients = 'deivide.rodrigues@gevan.com.br;mario.silva@gevan.com.br;eduardo.bispo@haltecnologia.com;fabio.dias@gevan.com.br;anapaula.santana@gevan.com.br',
	    @subject = @titulo, -- nvarchar(255)
	    @body = @HTML, -- nvarchar(max)
	    @body_format = 'html';
		
	END
GO

