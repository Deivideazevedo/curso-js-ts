BEGIN TRY    
    IF OBJECT_ID('tempdb..#TEMP', 'U') IS NOT NULL
    --IF OBJECT_ID('dbo.MinhaTabela', 'U') IS NOT NULL
    
	BEGIN
	    -- Se existir, a tabela temporária é excluída
	    DROP TABLE #TEMP;
	END;	
	-- OU
	--DROP TABLE IF EXISTS #TEMP
	
	CREATE TABLE #TEMP	
    (
        matricula INT,
        cargo VARCHAR(40),
        garagem VARCHAR(5),
        batida DATETIME,
        terminal VARCHAR(200),
        linha CHAR(6),
        esc_hr_inicio DATETIME,
        esc_hr_fim DATETIME
    );

END TRY
BEGIN CATCH
    -- Captura e exibe a mensagem de erro caso ocorra algum erro durante a criação da tabela
    PRINT 'Erro ao criar a tabela #TEMP: ' + ERROR_MESSAGE();
END CATCH


/*
	VERIFICAR PROCEDURES ONDE UMA TABELA ESTÁ SENDO UTILIZADA
*/

SELECT *
FROM sys.procedures
WHERE OBJECT_DEFINITION(object_id) LIKE '%INSERT INTO mpg_modelo_programacao%'