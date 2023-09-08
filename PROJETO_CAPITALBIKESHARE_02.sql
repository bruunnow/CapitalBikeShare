# 1- Qual a média de tempo (em segundos) de duração do aluguel de bike por tipo de membro?

SELECT
	tipo_membro,
    AVG(duracao_segundos) AS media_tempo_segundos
FROM
	cap06.tb_bikes02
GROUP BY
	tipo_membro;

################################################################

# 2- Qual a média de tempo (em segundos) de duração do aluguel de bike por tipo de membro e
# por estação fim (onde as bikes são entregues após o aluguel)?

SELECT
	tipo_membro,
    estacao_final,
    AVG(duracao_segundos) AS media_tempo_segundos
FROM
	cap06.tb_bikes02
GROUP BY
	tipo_membro, estacao_final
ORDER BY
	tipo_membro, estacao_final;
    
##################################################################

# 3- Qual a média de tempo (em segundos) de duração do aluguel de bike por tipo de membro e
# por estação fim (onde as bikes são entregues após o aluguel) ao longo do tempo?

SELECT
	tipo_membro,
    estacao_final,
	AVG(duracao_segundos) OVER (PARTITION BY tipo_membro ORDER BY data_inicio) AS media_tempo
FROM
	cap06.tb_bikes02;
    
##################################################################

# 4- Qual hora do dia (independente do mês) a bike de número W01182 teve o maior número de
# aluguéis considerando a data de início?

SELECT
	EXTRACT(HOUR FROM data_inicio) AS hora,
    COUNT(duracao_segundos) AS contagem_bike
FROM
	cap06.tb_bikes02
WHERE
	numero_bike = 'W01182'
GROUP BY
	hora
ORDER BY
	contagem_bike DESC;

#################################################################

# 5- Qual o número de aluguéis da bike de número W01182 ao longo do tempo considerando a
# data de início?

SELECT
	estacao_inicio,
    CAST(data_inicio AS DATE) AS data,
	COUNT(data_inicio) OVER (PARTITION BY estacao_inicio ORDER BY CAST(data_inicio AS DATE)) AS num_alugueis
FROM
	cap06.tb_bikes02
WHERE
	numero_bike = 'W01182';
    
##################################################################

# 6- Retornar:
# Estação fim, data fim de cada aluguel de bike e duração de cada aluguel em segundos
# Número de aluguéis de bikes (independente da estação) ao longo do tempo
# Somente os registros quando a data fim foi no mês de Abril

SELECT
	estacao_final,
    data_fim,
    duracao_segundos,
    COUNT(duracao_segundos) OVER (ORDER BY data_fim) AS contagem_temporal
FROM
	cap06.tb_bikes02
WHERE
	EXTRACT(MONTH FROM data_fim) = 04;
    
##############################################################

# 7- Retornar:
# Estação fim, data fim e duração em segundos do aluguel
# A data fim deve ser retornada no formato: 01/January/2012 00:00:00
# Queremos a ordem (classificação ou ranking) dos dias de aluguel ao longo do tempo
# Retornar os dados para os aluguéis entre 7 e 11 da manhã

SELECT
	estacao_final,
    DATE_FORMAT(data_fim, '%d/%M/%Y %T') AS data_fim,
    duracao_segundos,
   DENSE_RANK() OVER (PARTITION BY estacao_final ORDER BY data_inicio) AS rank_aluguel 
FROM
	cap06.tb_bikes02
WHERE
	EXTRACT(HOUR FROM data_fim) BETWEEN 07 AND 11;
    
############################################################################################

# 8- Qual a diferença da duração do aluguel de bikes ao longo do tempo, de um registro para
# outro, considerando data de início do aluguel e estação de início?
# A data de início deve ser retornada no formato: Sat/Jan/12 00:00:00 (Sat = Dia da semana
# abreviado e Jan igual mês abreviado). Retornar os dados para os aluguéis entre 01 e 03 da manhã

SELECT
	estacao_inicio,
    DATE_FORMAT(data_inicio, '%a/%b/%y %T') AS data_inicio,
    duracao_segundos,
    duracao_segundos - LAG(duracao_segundos, 1) OVER (PARTITION BY estacao_inicio ORDER BY CAST(data_inicio AS DATE)) AS diferenca
FROM
	cap06.tb_bikes02
WHERE
	EXTRACT(HOUR FROM data_fim) BETWEEN 01 AND 03;
    
#############################################################################################
    
# 9- Retornar:
# Estação fim, data fim e duração em segundos do aluguel
# A data fim deve ser retornada no formato: 01/January/2012 00:00:00
# Queremos os registros divididos em 4 grupos ao longo do tempo por partição
# Retornar os dados para os aluguéis entre 8 e 10 da manhã
# Qual critério usado pela função NTILE para dividir os grupos?

SELECT
	estacao_final,
    DATE_FORMAT(data_fim, '%d/%b/%Y %T') AS data_fim,
    duracao_segundos,
    NTILE(4) OVER (PARTITION BY estacao_final ORDER BY data_fim)
FROM
	cap06.tb_bikes02
WHERE
	EXTRACT(HOUR FROM data_fim) BETWEEN 08 AND 10;
    
################################################################################

# 10- Quais estações tiveram mais de 35 horas de duração total do aluguel de bike ao longo do
# tempo considerando a data fim e estação fim?
# Retorne os dados entre os dias '2012-04-01' e '2012-04-02'
# Dica: Use função window e subquery

SELECT 
	*
FROM
	(SELECT 
	estacao_final,
	CAST(data_fim AS DATE) AS data_fim,
	SUM(duracao_segundos/60/60) OVER (PARTITION BY estacao_final ORDER BY CAST(data_fim AS DATE)) AS tempo_total_horas
FROM
	cap06.tb_bikes02
WHERE
	data_fim BETWEEN '2012-04-01' AND '2012-04-02') resultado
WHERE
	tempo_total_horas > 35;
