ALTER PROCEDURE [dbo].[sp_sdo_rlt_frq_mar_jovem]  
    @cd_empresa     INT,
    @dt_inicial		DATETIME,
    @dt_final       DATETIME,
    @cd_processo    INT,
    @nm_janela      CHAR(65)

    AS
   
    DECLARE @tabela_funcionarios TABLE(cd_funcionario INT)
   
    INSERT INTO @tabela_funcionarios
    SELECT fnc_cd_funcionario FROM tmp_sel_funcionario WHERE processo = @cd_processo AND janela = @nm_janela;

	WITH situacao AS (
		SELECT 
			mar.fnc_cd_empresa, 
			mar.fnc_cd_funcionario,
			mar.mar_dt_mov, 
			SUM(IIF(mar.mar_cd_veiculo IS NULL OR mar.mar_cd_veiculo = 943,0,1)) AS situacao,
			count( DISTINCT IIF(mar.mar_cd_veiculo IS NULL,0,1) ) AS diferentes,
			count( IIF(mar.mar_cd_veiculo IS NULL,0,1) ) AS quantidade			
		FROM 
			mar_marcacao mar with(nolock)
		WHERE (mar.fnc_cd_empresa = @cd_empresa OR @cd_empresa = 0)
		    AND (mar.mar_dt_mov >= @dt_inicial)
		    AND (mar.mar_dt_mov <= @dt_final)
		    AND (mar.fnc_cd_funcionario IN (SELECT * FROM @tabela_funcionarios))
		GROUP BY mar.fnc_cd_empresa, mar.fnc_cd_funcionario, mar.mar_dt_mov
	),
	contagem AS (
		SELECT 
			mar.fnc_cd_empresa, 
			mar.fnc_cd_funcionario, 
			fnc.fnc_nm_funcionario,
			crg.crg_nm_cargo,
			mar.mar_dt_marcacao, 
			mar.mar_tp_marcacao, 
			mar.mar_cd_cracha, 
			mar.mar_id_marcacao, 
			mar.mar_dt_mov, 
			mar.mar_cd_justificativa, 
			mar.mar_st_situacao,
			mar.mar_cd_veiculo, 
			mar.mar_dt_hr_atualizacao,
			mar.mar_check_proc, 
			mar.mar_tp_operacao, 
			'+' AS flag,		
			ROW_NUMBER() OVER (PARTITION BY mar.fnc_cd_empresa, mar.fnc_cd_funcionario, mar.mar_dt_mov ORDER BY mar.fnc_cd_empresa, mar.fnc_cd_funcionario, mar.mar_dt_mov DESC) AS row,
			--s.situacao,
			--s.diferentes,
			s.quantidade,		
			CASE 
				WHEN s.situacao = 0 THEN 'Reserva'
				WHEN s.situacao > 0 AND s.diferentes = 1 THEN 'Normal'
				WHEN s.situacao > 0 AND s.diferentes > 1 THEN 'Mista'
				--ELSE 'TESTE'
			END AS st_fim
		FROM 
			mar_marcacao mar WITH (NOLOCK)
		LEFT JOIN 
			situacao s
			ON mar.fnc_cd_empresa = s.fnc_cd_empresa
			AND mar.fnc_cd_funcionario = s.fnc_cd_funcionario
			AND mar.mar_dt_mov = s.mar_dt_mov
		JOIN fnc_funcionario fnc
	        ON mar.fnc_cd_empresa = fnc.fnc_cd_empresa
	        AND mar.fnc_cd_funcionario = fnc.fnc_cd_funcionario
	    LEFT JOIN crg_cargo crg
	        ON crg.crg_cd_cargo = fnc.fnc_cd_cargo	        
		WHERE (mar.fnc_cd_empresa = @cd_empresa OR @cd_empresa = 0)
		    AND (mar.mar_dt_mov >= @dt_inicial)
		    AND (mar.mar_dt_mov <= @dt_final)
		    AND (mar.fnc_cd_funcionario IN (SELECT * FROM @tabela_funcionarios))
	)
	SELECT 
		* 
	FROM contagem
	WHERE row = 1
	ORDER BY mar_dt_mov 
GO

