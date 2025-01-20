ALTER PROCEDURE sp_sdo_upd_cod_odometro
	  @cd_empresa INT
	, @inicio_data DATETIME
	, @fim_data DATETIME
	, @cd_processo INT
	, @nm_janela CHAR(65)
AS 
BEGIN 
	
	SET NOCOUNT ON;
	DECLARE @cod_cd_empresa INT;
	DECLARE @cod_cd_garagem TINYINT;
	DECLARE @cod_dt_movimento DATETIME;
	DECLARE @cod_cd_veiculo INT;
	DECLARE @cod_nu_catraca INT;
	DECLARE @cod_nu_odometro DECIMAL(8, 1);
	DECLARE @cod_qt_ficha INT;
	DECLARE @cod_qt_quilometro DECIMAL(8, 1);
	
	DECLARE @resultado DECIMAL(8, 1);
	
	DECLARE @tabela_veiculos TABLE(cd_veiculo INT)
	
	INSERT INTO @tabela_veiculos
	SELECT vcl_cd_veiculo FROM tmp_sel_veiculo WHERE processo = @cd_processo AND janela = @nm_janela
	
	DROP TABLE IF EXISTS #temp;
	SELECT 
		* 
	INTO #temp 
	FROM cod_catraca_odometro 
	WHERE 
		cod_cd_empresa = @cd_empresa
		AND cod_cd_veiculo IN (
			SELECT vcl_cd_veiculo
			FROM vcl_veiculo WITH (NOLOCK)
			WHERE vcl_cd_veiculo IN (SELECT cd_veiculo FROM @tabela_veiculos )
		) 
		AND cod_dt_movimento >= @inicio_data
		AND cod_dt_movimento <= @fim_data
	ORDER BY cod_cd_veiculo;
	
	CREATE CLUSTERED INDEX idx_cod_veiculo_dt_movimento 
	ON #temp (cod_cd_veiculo, cod_dt_movimento);
		
	
	DECLARE veiculo_odometro_cursor CURSOR FOR
	SELECT DISTINCT cod_cd_veiculo FROM #temp WITH (NOLOCK);
	
	OPEN veiculo_odometro_cursor;
	
	FETCH veiculo_odometro_cursor INTO @cod_cd_veiculo;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- INICIO
		DECLARE odometro_cursor CURSOR FOR
		SELECT 
			*
		FROM #temp WITH (NOLOCK)
		WHERE cod_cd_veiculo = @cod_cd_veiculo
		ORDER BY cod_dt_movimento DESC;
	
		OPEN odometro_cursor;
								 
		FETCH odometro_cursor INTO @cod_cd_empresa, @cod_cd_garagem, @cod_dt_movimento, @cod_cd_veiculo, @cod_nu_catraca, @cod_nu_odometro, @cod_qt_ficha, @cod_qt_quilometro;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    
		    IF @resultado IS NOT NULL
		    BEGIN
		    
		        UPDATE #temp 
					SET cod_nu_odometro =  @resultado
		        WHERE 
		            cod_cd_empresa = @cod_cd_empresa AND
		            cod_cd_garagem = @cod_cd_garagem AND 
		            cod_dt_movimento = @cod_dt_movimento AND
		            cod_cd_veiculo = @cod_cd_veiculo AND 
		            cod_nu_catraca = @cod_nu_catraca AND
		            cod_nu_odometro = @cod_nu_odometro AND
		            cod_qt_ficha = @cod_qt_ficha AND
		            cod_qt_quilometro = @cod_qt_quilometro;
		         
		         SET  @cod_nu_odometro = @resultado;
		         
		    END
		
		    SET @resultado = @cod_nu_odometro - @cod_qt_quilometro; 
		    
		    FETCH odometro_cursor INTO @cod_cd_empresa, @cod_cd_garagem, @cod_dt_movimento, @cod_cd_veiculo, @cod_nu_catraca, @cod_nu_odometro, @cod_qt_ficha, @cod_qt_quilometro;
		END;
		
	  	SET @resultado = NULL;
	  	
		CLOSE odometro_cursor;
		DEALLOCATE odometro_cursor;
	  	
		-- FIM
		
	    FETCH veiculo_odometro_cursor INTO @cod_cd_veiculo;
	END;
	
	CLOSE veiculo_odometro_cursor;
	DEALLOCATE veiculo_odometro_cursor;
	
	
	UPDATE original 
		SET original.cod_nu_odometro = temp.cod_nu_odometro
	FROM 
		cod_catraca_odometro original, #temp temp
	WHERE
	    original.cod_cd_empresa 	= temp.cod_cd_empresa AND
	    original.cod_cd_garagem 	= temp.cod_cd_garagem AND 
	    original.cod_dt_movimento 	= temp.cod_dt_movimento AND
	    original.cod_cd_veiculo 	= temp.cod_cd_veiculo AND 
	    original.cod_nu_catraca 	= temp.cod_nu_catraca AND
	    original.cod_qt_ficha 		= temp.cod_qt_ficha AND
	    original.cod_qt_quilometro 	= temp.cod_qt_quilometro;
	
	
	--SELECT * FROM #temp
END
GO
