ALTER PROCEDURE sp_sdo_rel_ferias_premio
	  @cd_empresa INT
	, @dt_final DATETIME
	, @cd_processo INT
	, @nm_janela CHAR(65)
AS 
BEGIN 	
	DECLARE @emp_vetorh INT;
	
	
	DECLARE @tabela_funcionarios TABLE(cd_funcionario INT)
	DECLARE @tabela_item_frequencia TABLE(cd_item_frequencia INT)
   
   
	INSERT INTO @tabela_funcionarios
	SELECT fnc_cd_funcionario FROM tmp_sel_funcionario WHERE processo = @cd_processo AND janela = @nm_janela

	INSERT INTO @tabela_item_frequencia
	SELECT itf_cd_item_frequencia FROM tmp_sel_item_frequencia WHERE processo = @cd_processo AND janela = @nm_janela
	
	
	IF @cd_empresa = 10
	    SET @emp_vetorh = 11  
	ELSE IF @cd_empresa = 25
	    SET @emp_vetorh = 3
	ELSE IF  @cd_empresa = 30
	    SET @emp_vetorh = 7
	ELSE IF  @cd_empresa = 26
	    SET @emp_vetorh = 4	    

	 
	 -- Colaboradores sindicalizados
	;WITH sindicalizados AS (
		SELECT 
			numemp, numcad, max(datalt) AS datalt, max(socsin) AS socsin 
		FROM 
			vetorh..r038hsi with(nolock) --max(datalt) 
		where 
			tipcol = 1
			AND numemp = @emp_vetorh
			AND numcad IN (SELECT cd_funcionario FROM @tabela_funcionarios)
		    AND socsin = 'S' -- SINDICALIZADO
		GROUP BY numemp, numcad 
	),
	-- Incio das ferias: r040fem, período aquisitivo das ferias:r040per
	cte_ferias AS
	(
		Select 
			  r040per.numemp AS empresa
			, r040per.NumCad AS matricula
			, fnc.fnc_nm_funcionario
			, crg.crg_nm_cargo
			, r040per.tipcol
			, r040per.Iniper
			, r040per.Fimper
			, r040fem.inifer
			, row_number() OVER (PARTITION BY r040per.numemp, r040per.NumCad ORDER BY r040fem.inifer desc ) AS row
		FROM vetorh..r040fem WITH (nolock)
		INNER JOIN 
			vetorh..r040per
			ON r040per.numemp = r040fem.numemp 
			and r040per.tipcol = r040fem.tipcol 
			and r040per.numcad = r040fem.numcad
			and r040per.iniper = r040fem.iniper
		INNER JOIN 
		   	sindicalizados s
			ON s.numemp = r040fem.numemp 
			and s.numcad = r040fem.numcad
		LEFT JOIN 
	        fnc_funcionario fnc WITH (nolock)
	        ON fnc.fnc_cd_funcionario = r040fem.numcad
	    LEFT JOIN 
	        crg_cargo crg WITH (nolock)
	        ON crg.crg_cd_cargo = fnc.fnc_cd_cargo        
		where 
			r040per.numemp = @emp_vetorh
			and fnc.fnc_cd_empresa = @cd_empresa
			and r040per.tipcol = 1 
			and r040per.avofer = 12  
			and r040per.numcad IN (SELECT cd_funcionario FROM @tabela_funcionarios) -- (7977,7987)			
			and DATEADD(month, datediff(month,0,r040fem.inifer),0) = DATEADD(month, datediff(month,0,@dt_final),0)
	),
	Afastamento AS (
		Select 
			ferias.*
			,convert(VARCHAR(10),'Folha') AS local, convert(VARCHAR(90),afa.SitAfa) AS situacao, afa.DatAfa AS data_afa
		FROM 
			cte_ferias ferias
		LEFT JOIN 
			vetorh..R038AFA afa
			ON afa.numemp = ferias.empresa 
			and afa.numcad = ferias.matricula
			and afa.tipcol = ferias.tipcol 		
		where 
			afa.NumEmp = @emp_vetorh
			and afa.DatAfa  BETWEEN ferias.Iniper and ferias.Fimper
			and afa.SitAfa IN (15,11,26,112,404,18,14,3,16,8,117,006)
			
		UNION ALL
	
		SELECT 
			ferias.*
			,CONVERT(VARCHAR(10),'SDO') AS local, CONVERT(VARCHAR(90),itf.itf_ds_item_frequencia) AS situacao, fop.fop_dt_frequencia AS data_afa		   	
		FROM 
			cte_ferias ferias
		LEFT JOIN 
			fop_frequencia_operador fop WITH (nolock)
			ON fop.fnc_cd_funcionario = ferias.matricula
		LEFT JOIN itf_item_frequencia itf WITH (nolock)
	   		ON fop.itf_cd_item_frequencia = itf.itf_cd_item_frequencia  
		WHERE 
			fop.fnc_cd_empresa = @cd_empresa
			AND fop.fop_dt_frequencia BETWEEN ferias.Iniper and ferias.Fimper	
			AND (fop.itf_cd_item_frequencia IN (SELECT cd_item_frequencia FROM @tabela_item_frequencia) OR fop.itf_cd_item_frequencia IN (05,06,21,22,23,31,32,40,48,50,51,52,55,59,68,81,91,97))
	
	),
	Concatenatos AS (
		SELECT
		    empresa, matricula, data_afa, 
		    STUFF((
		        SELECT ' / ' + situacao
		        FROM Afastamento a2
		        WHERE a2.empresa = a1.empresa
		          AND a2.matricula = a1.matricula
		          AND a2.data_afa = a1.data_afa
		        FOR XML PATH('')
		    ), 1, 3, '') AS situacao,
		    STUFF((
		        SELECT ' / ' + local
		        FROM Afastamento a2
		        WHERE a2.empresa = a1.empresa
		          AND a2.matricula = a1.matricula
		          AND a2.data_afa = a1.data_afa
		        FOR XML PATH('')
		    ), 1, 3, '') AS local
		FROM Afastamento a1
		GROUP BY empresa, matricula, data_afa
	),
	FeriasComPremio AS (
	    -- Seleção dos funcionários em férias no mês desejado e verificação de prêmio
	    SELECT 
	        f.empresa, f.matricula, f.fnc_nm_funcionario, f.crg_nm_cargo AS cargo, f.Iniper AS iniper, Fimper AS fimper, inifer, 
	        CASE 
	            WHEN NOT EXISTS (
	                SELECT 1
	                FROM Concatenatos c
	                WHERE c.empresa = f.empresa 
	                AND c.matricula = f.matricula
	                AND c.data_afa BETWEEN f.Iniper AND f.Fimper
	            ) THEN 'Sim'
	            ELSE 'Não'
	        END AS Premio
	    FROM cte_ferias f
	)
	SELECT  
		f.empresa, f.matricula, f.fnc_nm_funcionario, f.cargo, f.iniper, f.fimper, f.inifer,
		convert(VARCHAR(20),local) AS local, convert(VARCHAR(90),c.situacao) AS situacao, c.data_afa, f.Premio COLLATE SQL_Latin1_General_CP1_CI_AS 
	FROM 
		FeriasComPremio f
	LEFT JOIN 
		Concatenatos c
		ON c.empresa = f.empresa
		AND c.matricula = f.matricula		
	ORDER by f.inifer, f.matricula, c.data_afa


END
GO

