--INSERINDO ULTIMO ABASTECIMENTO DE CADA VEICULO NA TABELA TEMPORARIA
WITH ultimo_abv AS ( 
	SELECT 
		abv_cd_empresa AS empresa, 
		abv_cd_garagem AS garagem, 
		abv_dt_abast AS data,
		CASE WHEN vcl.vcl_dt_desativacao IS NOT NULL THEN vcl_nu_ordem_antigo ELSE vcl.vcl_nu_ordem END AS nu_ordem,
		abv_nu_odometro AS odometro, 
		abv_qt_quilometro AS quilometro, 
		abv_qt_oleo AS qt_oleo,
		abv_cd_bomba AS bomba,
		ROW_NUMBER() OVER (PARTITION BY abv_cd_empresa, CASE WHEN vcl.vcl_dt_desativacao IS NOT NULL THEN vcl_nu_ordem_antigo ELSE vcl.vcl_nu_ordem END ORDER BY abv_dt_abast DESC) AS row  
	FROM abv_abast_veiculo abv
	LEFT JOIN vcl_veiculo vcl
		ON vcl.vcl_cd_empresa = abv.abv_cd_empresa
		AND vcl.vcl_cd_veiculo = abv.abv_cd_veiculo
	WHERE abv.abv_cd_empresa = 30
)
INSERT INTO tmp_gtfrota_ins_manual2
SELECT 
	abv.empresa, abv.garagem, abv.data, abv.nu_ordem, abv.odometro, abv.quilometro, abv.qt_oleo, abv.bomba
FROM ultimo_abv abv
LEFT JOIN tmp_gtfrota_ins_manual2 gtf
	ON gtf.empresa = abv.empresa AND gtf.garagem = abv.garagem AND gtf.nu_ordem = abv.nu_ordem AND gtf.data = abv.data AND gtf.odometro = abv.odometro
WHERE 
	abv.row = 1
	AND abv.nu_ordem IN (SELECT DISTINCT nu_ordem FROM tmp_gtfrota_ins_manual2 )
	AND gtf.empresa IS NULL -- Para trazer apenas os abastecimentos que nao tem na tmp_gtfrota_ins_manual2

/*
-- CALCULANDO NOVA QUILOMETRAGEM
WITH cte AS (
	SELECT *, 
	lag(odometro) OVER (PARTITION BY empresa, nu_ordem ORDER BY data) AS lag,
	ROW_NUMBER() OVER (PARTITION BY empresa, nu_ordem ORDER BY data) AS row  
	FROM tmp_gtfrota_ins_manual2
)
SELECT 
	*,
	CASE 
		WHEN cte.nu_ordem IN ('00060','00070') THEN 0
		WHEN cte.quilometro IS NOT NULL AND lag IS NULL THEN cte.quilometro
		WHEN cte.quilometro IS NULL AND lag IS NULL THEN 0
		WHEN cte.odometro >= cte.lag THEN cte.odometro - cte.lag
		WHEN cte.odometro < cte.lag THEN cte.lag
	END AS new_quilometro
FROM cte	


*/

-- ATUALIZANDO
;WITH cte AS (
	SELECT *, 
	lag(odometro) OVER (PARTITION BY empresa, nu_ordem ORDER BY data) AS lag
	FROM tmp_gtfrota_ins_manual2
)
UPDATE tmp_gtfrota_ins_manual2
SET quilometro =
	CASE 
		WHEN cte.nu_ordem IN ('00060','00070') THEN 0
		WHEN cte.quilometro IS NOT NULL AND lag IS NULL THEN cte.quilometro
		WHEN cte.quilometro IS NULL AND lag IS NULL THEN 0
		WHEN cte.odometro >= cte.lag THEN cte.odometro - cte.lag
		WHEN cte.odometro < cte.lag THEN cte.lag
	END 
FROM cte 
WHERE tmp_gtfrota_ins_manual2.empresa = cte.empresa
AND tmp_gtfrota_ins_manual2.data = cte.data
AND tmp_gtfrota_ins_manual2.nu_ordem = cte.nu_ordem



-- VERIFICANDO
SELECT 
*,	
ROW_NUMBER() OVER (PARTITION BY empresa, nu_ordem ORDER BY data) AS ROW 
FROM tmp_gtfrota_ins_manual2