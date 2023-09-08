# Duração total do aluguel das bikes (em horas)

SELECT 
	SUM(duracao_segundos/3600) AS total_horas 
FROM 
	cap06.tb_bikes;
    
################################################

# Duração total do aluguel das bikes (em horas), ao longo do tempo (soma acumulada)

SELECT 
	duracao_segundos,
	SUM(duracao_segundos/3600) OVER (ORDER BY data_inicio) AS duracao_total_acumulado
FROM 
	cap06.tb_bikes;

################################################

# Duração total do aluguel das bikes (em horas), ao longo do tempo, por estação de início do aluguel da bike,
# quando a data de início foi inferior a '2012-01-08'

SELECT estacao_inicio,
	duracao_segundos,
	SUM(duracao_segundos/3600) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS tempo_total_horas
FROM
	cap06.tb_bikes
WHERE
	data_inicio < '2012-01-08';
    
#################################################

# Qual a média de tempo (em horas) de aluguel de bike da estação de início 31017?

SELECT
	estacao_inicio,
    numero_estacao_inicio,
    AVG(duracao_segundos/3600) AS media_tempo_horas
FROM
	cap06.tb_bikes
WHERE
	numero_estacao_inicio = '31017'
GROUP BY
	estacao_inicio, numero_estacao_inicio;
    
#################################################

# Qual a média de tempo (em horas) de aluguel da estação de início 31017, ao longo do tempo (média móvel)?

SELECT 
	estacao_inicio,
	AVG(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS media_tempo_aluguel
FROM
	cap06.TB_BIKES
WHERE
	numero_estacao_inicio = 31017;
    
#################################################

# Retornar:
# Estação de início, data de início e duração de cada aluguel de bike em segundos
# Duração total de aluguel das bikes ao longo do tempo por estação de início
# Duração média do aluguel de bikes ao longo do tempo por estação de início
# Número de aluguéis de bikes por estação ao longo do tempo 
# Somente os registros quando a data de início for inferior a '2012-01-08'

SELECT
	estacao_inicio,
    data_inicio,
    duracao_segundos,
    SUM(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) as duracao_total_aluguel,
    AVG(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS duracao_media_aluguel,
    COUNT(estacao_fim) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS numero_alugueis
FROM
	cap06.tb_bikes
WHERE 
	data_inicio < '2012-01-08';
    
############################################################

# Retornar:
# Estação de início, data de início de cada aluguel de bike e duração de cada aluguel em segundos
# Número de aluguéis de bikes (independente da estação) ao longo do tempo 
# Somente os registros quando a data de início for inferior a '2012-01-08'

# Solução 1

SELECT
	estacao_inicio,
    data_inicio,
    duracao_segundos,
    COUNT(estacao_fim) OVER (ORDER BY data_inicio) AS numero_alugueis
FROM
	cap06.tb_bikes
WHERE 
	data_inicio < '2012-01-08';
    
## Solução 2

SELECT
	estacao_inicio,
    data_inicio,
    duracao_segundos,
    ROW_NUMBER() OVER (ORDER BY data_inicio) AS numero_alugueis
FROM
	cap06.tb_bikes
WHERE 
	data_inicio < '2012-01-08';
    
###########################################################
    
# E se quisermos o mesmo resultado anterior, mas a contagem por estação?

SELECT
	estacao_inicio,
    data_inicio,
    duracao_segundos,
    ROW_NUMBER() OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS numero_alugueis
FROM
	cap06.tb_bikes
WHERE 
	data_inicio < '2012-01-08';
    
############################################################

# Qual a diferença da duração do aluguel de bikes ao longo do tempo, de um registro para outro?
SELECT estacao_inicio,
       CAST(data_inicio as date) AS data_inicio,
       duracao_segundos,
       duracao_segundos - LAG(duracao_segundos, 1) OVER (PARTITION BY estacao_inicio ORDER BY CAST(data_inicio as date)) AS diferenca
FROM cap06.TB_BIKES
WHERE data_inicio < '2012-01-08'
AND numero_estacao_inicio = 31000;

# Usando subquery para retirar o registro nulo. 

SELECT *
  FROM (
    SELECT estacao_inicio,
           CAST(data_inicio as date) AS data_inicio,
           duracao_segundos,
           duracao_segundos - LAG(duracao_segundos, 1) OVER (PARTITION BY estacao_inicio ORDER BY CAST(data_inicio as date)) AS diferenca
      FROM cap06.TB_BIKES
     WHERE data_inicio < '2012-01-08'
     AND numero_estacao_inicio = 31000) resultado
 WHERE resultado.diferenca IS NOT NULL;

