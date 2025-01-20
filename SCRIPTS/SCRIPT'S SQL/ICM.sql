
--DROP TABLE IF EXISTS icm_int_cittati_manual 	
CREATE TABLE icm_int_cittati_manual (
	icm_id INT IDENTITY(1,1),
	icm_cd_empresa INT,
	icm_tipo VARCHAR(100),
	icm_data DATETIME,
	icm_usuario VARCHAR(100),
	icm_dt_sdo DATETIME DEFAULT CAST(getdate() AS DATE),
	icm_dtime_sdo DATETIME DEFAULT GETDATE(),
	icm_dt_ini_py DATETIME NULL,
	icm_dt_fim_py DATETIME NULL,
	icm_status VARCHAR(30) NULL
);
SELECT * FROM icm_int_cittati_manual

INSERT INTO icm_int_cittati_manual 
(icm_cd_empresa, icm_tipo, icm_data, icm_usuario) VALUES 
(10,'Viagens','08/01/2025','deivide.azevedo')

 
SELECT TOP 1 icm_id, icm_cd_empresa, icm_tipo, icm_data, icm_usuario, icm_dt_sdo, icm_dtime_sdo, icm_dt_ini_py, icm_dt_fim_py, icm_status FROM icm_int_cittati_manual
WHERE icm_tipo = 'ROV''s' AND icm_dt_ini_py IS NULL AND NOT EXISTS ( SELECT 1 FROM icm_int_cittati_manual WHERE icm_tipo = 'ROV''s' and icm_status = 'Em execução') ORDER BY icm_dtime_sdo

SELECT * FROM icm_int_cittati_manual
SELECT * FROM tmp_int_sdo_gss WHERE dt_ope = '17/01/2025'

UPDATE producao_ho1..icm_int_cittati_manual
SET icm_dt_ini_py = NULL, icm_dt_fim_py = NULL, icm_status = 'Em fila'
WHERE icm_id = 28

'16/01/2025 12:28:19'
'Em execução'

SELECT * FROM icm_int_cittati_manual WITH(nolock) WHERE icm_data = '16/01/2025'
SELECT * FROM rvv_rov_viagem WITH(nolock) WHERE rvv_dt_operacao = '16/01/2025'



