DECLARE 
	@cd_emp INT = 10,
	@cd_mpg INT = 311370,
	@esm_tp_dia CHAR = '0',
	@dt_ini DATETIME = '24/09/2024',
	@dt_fim DATETIME = '24/09/2024';
	
   
	
WITH cte_ept AS (
	SELECT  
	ept_cd_empresa, 
	ept_cd_programacao,	
	ept_cd_id_servico,	
	ept_cd_tipo_evento,
	ept_tp_servico,
	ept_nu_onibus,	
	ept_hr_ini,	ept_hr_fim,	
	DATEDIFF(mi, ept_hr_ini, ept_hr_fim) AS duracao
	--MAX (ept_hr_fim) OVER (PARTITION BY ept_cd_id_servico ORDER BY ept_cd_id_servico) AS max, 
	--MIN (ept_hr_ini) OVER (PARTITION BY ept_cd_id_servico ORDER BY ept_cd_id_servico) AS min
	FROM ept_evento_freq_func
	WHERE ept_cd_empresa = @cd_emp  AND ept_cd_programacao IN ( @cd_mpg )  	
),

cte_evento AS (
	SELECT 
		ept_cd_empresa,
		ept_cd_programacao,
		ept_cd_id_servico AS tripulante,
		ept_tp_servico,
		ept_nu_onibus,
		MIN (ept_hr_ini) AS hora_inicio,
		MAX (ept_hr_fim) AS hora_fim,
		--MAX (ept_hr_fim) - MIN (ept_hr_ini) AS jornada_exata,
	    DATEADD(mi,SUM (duracao),0) AS hora_jornada, -- Jornada por evento
		DATEADD(mi, SUM (CASE WHEN ept_cd_tipo_evento IN ('GT', 'GTS', 'TG', 'TGR', 'Vgm') THEN duracao ELSE 0 END),0) AS hora_produtiva,
		DATEADD(mi, SUM (CASE WHEN ept_cd_tipo_evento IN ('GT', 'GTS', 'TG', 'TGR', 'Vgm', 'Pars') THEN duracao ELSE 0 END),0) AS hora_jornada_remunerada,
		DATEADD(mi, SUM (CASE WHEN ept_cd_tipo_evento = 'desc' THEN duracao ELSE 0 END),0) AS hora_descanso,
		DATEADD(mi, SUM (CASE WHEN ept_cd_tipo_evento = 'Pars' THEN duracao ELSE 0 END),0) AS hora_improdutiva,		
		CASE 		   
			WHEN 	(MIN (ept_hr_ini) >= '01/01/1900 22:00:00' AND MIN (ept_hr_ini) < '02/01/1900 05:00:00')                -- COMEÇOU E TERMINOU ENTRE 22 E 05
				AND (MAX (ept_hr_fim) > '01/01/1900 22:00:00' AND MAX (ept_hr_fim) <= '02/01/1900 05:00:00')
				AND MAX (ept_hr_fim) > MIN (ept_hr_ini)
			   THEN MAX (ept_hr_fim) - MIN (ept_hr_ini)    
			                                                                 
			WHEN 	(MIN (ept_hr_ini) >= '01/01/1900 22:00:00' AND MIN (ept_hr_ini) < '02/01/1900 05:00:00')                -- COMEÇOU ENTRE (22 e 05) E TERMINOU DEPOIS DE 05
				AND (MAX (ept_hr_fim) > '02/01/1900 05:00:00')
				AND MAX (ept_hr_fim) > MIN (ept_hr_ini)				
			   THEN  CONVERT(DATETIME,'05/02/1900 22:00:00') - MIN (ept_hr_ini) 
			     
			WHEN MIN (ept_hr_ini) < '01/01/1900 05:00:00' THEN  CONVERT(DATETIME,'01/01/1900 05:00:00') - MIN (ept_hr_ini)  -- COMEÇOU ANTES DE 05 HRS 
			WHEN MAX (ept_hr_fim) > '01/01/1900 22:00:00' AND MAX (ept_hr_fim) <= '02/01/1900 05:00:00' THEN  MAX (ept_hr_fim) - CONVERT(DATETIME,'01/01/1900 22:00:00')  -- TERMINOU DEPOIS DE 22 HRS
			
		ELSE 0 END AS adicional_noturno,
		
		DATEADD(mi,IIF(SUM (CASE WHEN ept_cd_tipo_evento IN ('GT', 'GTS', 'TG', 'TGR', 'Vgm', 'Pars') THEN duracao ELSE 0 END) > 420 
			AND SUM (CASE WHEN ept_cd_tipo_evento IN ('GT', 'GTS', 'TG', 'TGR', 'Vgm', 'Pars') THEN duracao ELSE 0 END) < 540, 
			SUM (CASE WHEN ept_cd_tipo_evento IN ('GT', 'GTS', 'TG', 'TGR', 'Vgm', 'Pars') THEN duracao ELSE 0 END) - 420, 0
		),0) AS horas_50,
		
		DATEADD(mi,IIF(SUM (CASE WHEN ept_cd_tipo_evento IN ('GT', 'GTS', 'TG', 'TGR', 'Vgm', 'Pars') THEN duracao ELSE 0 END) > 540, 
			SUM (CASE WHEN ept_cd_tipo_evento IN ('GT', 'GTS', 'TG', 'TGR', 'Vgm', 'Pars') THEN duracao ELSE 0 END) - 540, 0
		),0) AS horas_100

	FROM cte_ept
	GROUP BY ept_cd_empresa, ept_cd_programacao, ept_cd_id_servico, ept_tp_servico, ept_nu_onibus
)
SELECT  --* FROM cte_evento
	concat(convert(VARCHAR,sum(datediff(mi,0,hora_jornada)) OVER(PARTITION BY ept.ept_cd_programacao) / 60),':',convert(VARCHAR,sum(datediff(mi,0,hora_jornada)) OVER(PARTITION BY ept.ept_cd_programacao) % 60)) AS T_jornada, 
	concat(convert(VARCHAR,sum(datediff(mi,0,hora_produtiva)) OVER(PARTITION BY ept.ept_cd_programacao) / 60),':',convert(VARCHAR,sum(datediff(mi,0,hora_produtiva)) OVER(PARTITION BY ept.ept_cd_programacao) % 60)) AS T_hora_produtiva, 
	ept.ept_cd_programacao,
	mpg.mpg_ds_modelo_programacao AS programacao, 
	ept.tripulante, 
	ept.hora_inicio, 
	ept.hora_fim, 
	ept.hora_jornada, 
	ept.hora_produtiva,  
	ept.hora_descanso, 
	ept.hora_improdutiva, 
	ept.hora_jornada_remunerada,
	ept.horas_50, 
	ept.horas_100,
	ept.adicional_noturno, 
	'' AS tipo_jornada,
	ept.ept_tp_servico,
	ept.ept_nu_onibus,
	esm.esm_tp_dia
FROM	
	cte_evento ept
JOIN mpg_modelo_programacao mpg WITH(NOLOCK)
	ON  mpg.mpg_cd_modelo_programacao = ept.ept_cd_programacao
LEFT JOIN esm_modelo_escala esm WITH(NOLOCK)
	ON esm.esm_cd_empresa = ept.ept_cd_empresa  AND esm.esm_cd_modelo_programacao = ept.ept_cd_programacao
WHERE 
	ept.ept_cd_empresa = @cd_emp
  	AND ept.ept_cd_programacao  IN ( @cd_mpg )  	
  	AND (esm.esm_dt_operacao >= @dt_ini AND esm.esm_dt_operacao <= @dt_fim)
	AND (esm.esm_tp_dia = @esm_tp_dia OR @esm_tp_dia = '0')
/*
SELECT DISTINCT esm_tp_dia FROM esm_modelo_escala
WHERE 
esm_tp_dia > 1 AND 
esm_dt_operacao > '24/09/2024'
*/
/*
SELECT * FROM esm_modelo_escala
WHERE 
esm_cd_modelo_programacao = 2824*/