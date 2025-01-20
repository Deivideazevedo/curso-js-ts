DECLARE @cd_emp INT = 25;
DECLARE @date_import DATETIME = '13/01/2024';

INSERT INTO abv_abast_veiculo
SELECT DISTINCT
    empresa
    , garagem
    , data
    , IIF(bomba = 0, 1, bomba) AS bomba
    , 1 AS turno
    , vcl_veiculo.vcl_cd_veiculo
    , qt_oleo
    , NULL AS qt_oleo_lub
    , odometro
    , quilometro
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
FROM tmp_gtfrota_ins_manual2
LEFT JOIN vcl_veiculo
	ON vcl_veiculo.vcl_cd_empresa = tmp_gtfrota_ins_manual2.empresa 
	AND vcl_veiculo.vcl_nu_ordem  = tmp_gtfrota_ins_manual2.nu_ordem COLLATE SQL_Latin1_General_CP1_CI_AS 
LEFT JOIN abv_abast_veiculo
	ON abv_abast_veiculo.abv_cd_empresa = empresa
	AND abv_abast_veiculo.abv_cd_garagem = garagem
	AND abv_abast_veiculo.abv_dt_abast = data
	--AND abv_abast_veiculo.abv_cd_bomba = 1
	--AND abv_abast_veiculo.abv_nu_turno = 1
	AND abv_abast_veiculo.abv_cd_veiculo = vcl_veiculo.vcl_cd_veiculo
	--AND ISNULL(vcl_veiculo.vcl_nu_ordem_antigo,vcl_veiculo.vcl_nu_ordem)  = tmp_gtfrota_ins_manual.nu_ordem
WHERE 
	empresa = @cd_emp
	AND abv_abast_veiculo.abv_cd_empresa IS NULL
	AND vcl_veiculo.vcl_cd_veiculo IS NOT NULL
	AND data >= @date_import
ORDER BY data


/*

SELECT * FROM abv_abast_veiculo
WHERE abv_dt_abast >= '02/01/2025'


*/

/*
SELECT *, ROW_NUMBER() OVER (PARTITION BY abv_cd_empresa, abv_cd_veiculo ORDER BY abv_dt_abast) FROM abv_abast_veiculo
WHERE abv_dt_abast >= '12/12/2024'
*/