DROP SCHEMA urgencia cascade

CREATE DATABASE dw_urgencia_hospital;

CREATE SCHEMA urgencia;

CREATE TABLE urgencia.dim_hospital (
    id_hospital integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome_hospital varchar(50) NOT NULL,
    localizacao varchar(50) NOT NULL  
);

CREATE TABLE urgencia.dim_paciente (
    id_paciente integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(50) NOT NULL,
    genero varchar(50) NOT NULL,
    data_nascimento date NOT NULL,
    idade integer NOT NULL,
    nacionalidade varchar(50) NOT NULL,
    localidade varchar(50) NOT NULL,
    NIF varchar(50)
);

CREATE TABLE urgencia.dim_tempo (
	id_tempo integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tempo timestamp,
	data date,
	dia integer,
	mes integer,
	ano integer,
	hora time,
	dia_da_semana integer,
	turno varchar(20)
);

CREATE TABLE urgencia.dim_ocorrencia (
	id_ocorrencia integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	estado_ocorrencia varchar(10) CHECK (estado_ocorrencia IN ('Ativo', 'Inativo')) NOT NULL,
	codigo_prioridade varchar(10) CHECK (codigo_prioridade IN ('Vermelho', 'Laranja', 'Amarelo', 'Verde', 'Azul')) NOT NULL,
	tipologia_ocorrencia varchar(50) NOT NULL,
	grau_patologia varchar(10) CHECK (grau_patologia IN ('Ligeiro', 'Moderado', 'Grave')) NOT NULL
);

CREATE TABLE urgencia.dim_infraestruturas (
	id_infraestrutura integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	categoria varchar(50) NOT NULL,
	codigo varchar(50) NOT NULL,
	piso varchar(50) NOT NULL,
	especialidade varchar(50) NOT NULL,
	nome_hospital varchar(50) NOT null,
	data_entrada date NOT NULL,
	data_saida date
);

CREATE TABLE urgencia.dim_infra_ocup (
	id_dim_infra_ocup integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_infraestrutura integer,
	tempo_inicio timestamp NOT NULL,
	tempo_fim timestamp NOT NULL,
	FOREIGN KEY (id_infraestrutura) REFERENCES urgencia.dim_infraestruturas (id_infraestrutura)
);

CREATE TABLE urgencia.dim_prof_saude (
	id_profissional integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	nome varchar(50) NOT NULL,
	cargo varchar(50) NOT NULL,
	especialidade varchar(50) NOT NULL,
	nome_hospital varchar(50) NOT NULL,
	data_entrada date NOT NULL,
	data_saida date
);

CREATE TABLE urgencia.dim_prof_saude_ocup (
	id_prof_ocup integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_profissional integer,
	tempo_inicio timestamp NOT NULL, 
	tempo_fim timestamp NOT NULL,
	FOREIGN KEY (id_profissional) REFERENCES urgencia.dim_prof_saude (id_profissional)
);

CREATE TABLE urgencia.fact_episodio_urgencia (
	id_hospital integer,
	id_paciente integer,
	id_tempo_chegada integer,
	id_tempo_triagem integer,
	id_tempo_atendimento integer,
	id_tempo_alta integer,
	id_ocorrencia integer,
	id_infraestrutura integer,
	id_profissional integer,
	t_espera_triagem decimal NOT NULL,
	t_espera_atendimento decimal NOT NULL,
	t_espera_alta decimal NOT NULL,
	t_espera_total decimal NOT NULL,
	FOREIGN KEY (id_hospital) REFERENCES urgencia.dim_hospital (id_hospital),
	FOREIGN KEY (id_paciente) REFERENCES urgencia.dim_paciente (id_paciente),
  	FOREIGN KEY (id_tempo_chegada) REFERENCES urgencia.dim_tempo (id_tempo),
  	FOREIGN KEY (id_tempo_triagem) REFERENCES urgencia.dim_tempo (id_tempo),
  	FOREIGN KEY (id_tempo_atendimento) REFERENCES urgencia.dim_tempo (id_tempo),
  	FOREIGN KEY (id_tempo_alta) REFERENCES urgencia.dim_tempo (id_tempo),
  	FOREIGN KEY (id_ocorrencia) REFERENCES urgencia.dim_ocorrencia (id_ocorrencia),
  	FOREIGN KEY (id_infraestrutura) REFERENCES urgencia.dim_infraestruturas (id_infraestrutura),
  	FOREIGN KEY (id_profissional) REFERENCES urgencia.dim_prof_saude (id_profissional)
);

INSERT INTO urgencia.dim_tempo(tempo)
SELECT generate_series(
    '2025-01-01 00:00'::timestamp,
    CURRENT_TIMESTAMP,
    '1 minute'
);

UPDATE urgencia.dim_tempo
SET 
	data = tempo::date,
    dia = EXTRACT(day FROM tempo)::int,
    mes = EXTRACT(month FROM tempo)::int,
    ano = EXTRACT(year FROM tempo)::int,
    hora = tempo::time,
    dia_da_semana = EXTRACT(dow FROM tempo)::int,
	turno = case 
				WHEN tempo::time BETWEEN '06:00:00' AND '12:59:59' THEN 'Manhã'
                WHEN tempo::time BETWEEN '13:00:00' AND '20:59:59' THEN 'Tarde'
                ELSE 'Noite'
        	end;

INSERT INTO urgencia.dim_hospital(nome_hospital,localizacao) VALUES
     ('Hospital de Braga','Braga'),
     ('Centro Hospitalar Universitário de São João','Porto'),
     ('Hospital de Santa Maria','Lisboa'),
     ('Hospital Garcia de Orta','Almada'),
     ('Centro Hospitalar Universitário do Algarve – Faro','Faro'),
     ('Hospital de Vila Real (CHTMAD)','Vila Real'),
     ('Hospital de Aveiro (CHBV)','Aveiro'),
     ('Hospital da Luz Lisboa','Lisboa'),
     ('Hospital de Leiria','Leiria'),
     ('Hospital Espírito Santo de Évora','Évora');

INSERT INTO urgencia.dim_paciente(nome,genero,data_nascimento,idade,nacionalidade,localidade,nif) VALUES
('Maria Ferreira','feminino','1999-11-18',25,'Portuguesa','Braga','253456765'),
('João Marques','masculino','1988-07-02',36,'Portuguesa','Porto','234567890'),
('Ana Ribeiro','feminino','2000-03-14',24,'Portuguesa','Lisboa','278901345'),
('Tiago Santos','masculino','1995-01-29',29,'Portuguesa','Coimbra','265443221'),
('Carla Matos','feminino','1982-05-22',42,'Portuguesa','Guimarães','298764553'),
('Bruno Almeida','masculino','1991-09-11',33,'Brasileira','Faro','289123890'),
('Sofia Veloso','feminino','1987-04-10',37,'Portuguesa','Viseu','251897432'),
('Ricardo Teixeira','masculino','2002-12-01',22,'Portuguesa','Aveiro','231998765'),
('Marta Gonçalves','feminino','1990-02-08',35,'Portuguesa','Évora','298340112'),
('Pedro Correia','masculino','1983-08-19',41,'Portuguesa','Leiria','223498776');

INSERT INTO urgencia.dim_ocorrencia(estado_ocorrencia, codigo_prioridade, tipologia_ocorrencia, grau_patologia) VALUES
('Ativo','Vermelho','Acidente','Grave'),
('Ativo','Laranja','Outros','Moderado'),
('Ativo','Laranja','Outros','Ligeiro'),
('Inativo','Azul','Outros','Moderado'),
('Ativo','Amarelo','Surto sazonal','Ligeiro');

INSERT INTO urgencia.dim_infraestruturas(categoria, codigo, piso, especialidade,nome_hospital,data_entrada,data_saida) VALUES
('sala de triagem','TR-01',1,'triagem','Hospital de Braga','2024-01-02',NULL),
('sala de triagem','TR-02',1,'triagem','Hospital de Vila Real (CHTMAD)','2024-01-05',NULL),
('gabinete médico','GM-01',2, 'Cardiologia','Hospital de Braga','2024-01-07',NULL),
('gabinete médico','GM-02',3, 'Psiquiatria','Hospital de Braga','2024-01-06',NULL),
('quarto de internamento','QI-01',2,'Cardiologia','Hospital de Braga','2024-01-09',NULL),
('quarto de internamento','QI-02',3,'Psiquiatria','Hospital de Braga','2024-01-09',NULL),
('quarto de internamento','QI-03',4,'Cirurgia geral','Hospital de Braga','2024-01-13',NULL),
('cama de observação','CO-01',2,'Cardiologia','Hospital de Braga','2024-01-12',NULL),
('cama de observação','CO-02',3,'Psiquiatria','Hospital de Braga','2024-01-12',NULL),
('cama de observação','CO-03',4,'Cirurgia geral','Hospital de Vila Real (CHTMAD)','2024-01-12',NULL);

INSERT INTO urgencia.dim_prof_saude(nome, cargo, especialidade, nome_hospital,data_entrada,data_saida) VALUES
('Joana Martins','Técnico de triagem','Triagem','Hospital de Braga','2024-01-15',NULL),
('Paula Soares','Técnico de triagem','Triagem','Hospital de Vila Real (CHTMAD)','2024-01-20',NULL),
('Alexandre Reis','Médico','Cardiologia','Hospital de Braga','2024-01-12',NULL),
('Pedro Martins','Médico','Psiquiatria','Hospital de Braga','2024-01-23',NULL),
('João Afonso','Médico','Cirurgia geral','Hospital de Braga','2024-01-12',NULL),
('Maria Fonseca','Enfermeiro','Cardiologia','Hospital de Braga','2024-01-12',NULL),
('Mariana Bessa','Enfermeiro','Psiquiatria','Hospital de Braga','2024-01-12',NULL),
('Teresa Martins','Enfermeiro','Cirurgia geral','Hospital de Vila Real (CHTMAD)','2024-01-12',NULL);

INSERT INTO urgencia.dim_infra_ocup(id_infraestrutura,tempo_inicio,tempo_fim) values
(1,'2025-01-01 03:22:00','2025-01-01 03:40:00'),
(1,'2025-01-01 03:39:00','2025-01-01 04:10:00'),
(1,'2025-01-01 09:09:00','2025-01-01 09:20:00'),
(1,'2025-01-01 06:39:00','2025-01-01 06:50:00'),
(2,'2025-01-01 07:49:00','2025-01-01 08:10:00'),
(3,'2025-01-01 05:39:00','2025-01-01 07:20:00'),
(6,'2025-01-01 09:09:00','2025-01-01 11:08:00'),
(7,'2025-01-01 06:39:00','2025-01-01 09:20:00'),
(9,'2025-01-01 11:39:00','2025-01-01 20:10:00'),
(10,'2025-01-01 09:59:00','2025-01-01 12:30:00');

INSERT INTO urgencia.dim_prof_saude_ocup(id_profissional, tempo_inicio,tempo_fim) VALUES
(1,'2025-01-01 03:22:00','2025-01-01 03:40:00'),
(1,'2025-01-01 03:39:00','2025-01-01 04:10:00'),
(1,'2025-01-01 09:09:00','2025-01-01 09:20:00'),
(1,'2025-01-01 06:39:00','2025-01-01 06:50:00'),
(2,'2025-01-01 07:49:00','2025-01-01 08:10:00'),
(5,'2025-01-01 06:39:00','2025-01-01 09:20:00'),
(3,'2025-01-01 05:39:00','2025-01-01 07:20:00'),
(4,'2025-01-01 09:09:00','2025-01-01 11:08:00'),
(8,'2025-01-01 09:59:00','2025-01-01 12:30:00'),
(4,'2025-01-01 11:39:00','2025-01-01 20:10:00');


INSERT INTO urgencia.fact_episodio_urgencia(id_hospital,id_paciente,id_tempo_chegada,id_tempo_triagem,id_tempo_atendimento,id_tempo_alta,id_ocorrencia,id_infraestrutura,id_profissional,t_espera_triagem,t_espera_atendimento, t_espera_alta,t_espera_total) VALUES
(1,1,101,203,400,470,1,1,1,1.70,3.28,1.17,6.15),
(1,1,101,203,400,470,1,7,5,1.70,3.28,1.17,6.15),

(1,2,203,220,340,500,2,1,1,0.28,2.00,2.83,5.12),
(1,2,203,220,340,500,2,3,3,0.28,2.00,2.83,5.12),

(1,3,305,400,550,600,3,1,1,1.58,2.50,0.83,4.92),
(1,3,305,400,550,600,3,6,4,1.58,2.50,0.83,4.92),

(1,4,410,470,700,810,4,1,1,1.00,3.83,1.83,6.67),
(1,4,410,470,700,810,4,9,4,1.00,3.83,1.83,6.67),

(6,5,510,550,600,700,5,2,2,0.67,0.83,1.67,3.17),
(6,5,510,550,600,700,5,10,8,0.67,0.83,1.67,3.17);

--update tabela paciente
UPDATE urgencia.dim_paciente 
SET localidade='Braga' WHERE id_paciente=2;
SELECT * FROM urgencia.dim_paciente WHERE id_paciente=2;

--update tabela hospital
UPDATE urgencia.dim_hospital 
SET nome_hospital='Hospital da Luz' WHERE id_hospital=8;
SELECT * FROM urgencia.dim_hospital WHERE id_hospital=8;

--update tabela de infraestutura
UPDATE urgencia.dim_infraestruturas 
SET codigo='QI-05' WHERE id_infraestrutura=5;
SELECT * FROM urgencia.dim_infraestruturas WHERE id_infraestrutura=5;

--delete id_paciente=4 da tabela de facto
DELETE FROM  urgencia.fact_episodio_urgencia WHERE id_paciente=4;
SELECT * FROM urgencia.fact_episodio_urgencia WHERE id_paciente=4;

DELETE FROM urgencia.dim_paciente WHERE id_paciente=4;
SELECT * FROM urgencia.dim_paciente WHERE id_paciente=4;

--delete id_paciente=4 da tabela de paciente
ALTER TABLE urgencia.fact_episodio_urgencia
DROP constraint fact_episodio_urgencia_id_hospital_fkey,
ADD constraint fact_episodio_urgencia_id_hospital_fkey
	foreign key (id_hospital)
	REFERENCES urgencia.dim_hospital(id_hospital)
	ON DELETE cascade;

-- delete id_hospital=6 da tabela de hospital (delete em cascade)
DELETE FROM urgencia.dim_hospital WHERE id_hospital=6;
SELECT * FROM urgencia.dim_hospital WHERE id_hospital=6;
SELECT * FROM urgencia.fact_episodio_urgencia WHERE id_hospital=6;

--EX1: para pacientes com pulseira laranja, queremos saber os tempos de espera por genero
SELECT 
	p.genero,
	AVG(a.tempo_unico_triagem) as média_tempo_chegada_triagem,
	AVG(a.tempo_unico_atendimento) as média_tempo_triagem_atend,
	AVG(a.tempo_unico_alta) as média_tempo_atend_alta
FROM (
    SELECT 
        e.id_hospital,
    	e.id_paciente,
    	e.id_ocorrencia,
        e.id_tempo_chegada,
        AVG(e.t_espera_triagem) as tempo_unico_triagem,
        AVG(e.t_espera_atendimento) as tempo_unico_atendimento,
        AVG(e.t_espera_alta) as tempo_unico_alta
    FROM urgencia.fact_episodio_urgencia e
    GROUP BY id_hospital, id_paciente, id_ocorrencia,id_tempo_chegada
) a
JOIN urgencia.dim_paciente p
ON a.id_paciente = p.id_paciente
JOIN urgencia.dim_ocorrencia o
ON a.id_ocorrencia = o.id_ocorrencia
WHERE o.codigo_prioridade = 'Laranja'
GROUP BY p.genero;

--EX2:
--Para ocorrencias com grau de patologia moderado queremos saber o número de ocorrencias e a média do tempo de atendimento por turno
---tivemos 2 ocorrências, uma de manhã e outra à noite, durante o periodo da manhã o tempo de espera foi superior

SELECT 
	t.turno, 
	COUNT(a.tempo_aten_unico) as número_ocorrências, 
	AVG(a.tempo_aten_unico) as média_tempo_triagem_atend
FROM (
    SELECT 
        e.id_hospital,
    	e.id_paciente,
    	e.id_ocorrencia,
        e.id_tempo_atendimento,
        AVG(e.t_espera_atendimento) as tempo_aten_unico
    FROM urgencia.fact_episodio_urgencia e
    GROUP BY id_hospital, id_paciente, id_ocorrencia,id_tempo_atendimento
) a
JOIN urgencia.dim_tempo t
ON a.id_tempo_atendimento = t.id_tempo
JOIN urgencia.dim_ocorrencia o
ON a.id_ocorrencia = o.id_ocorrencia
WHERE o.grau_patologia = 'Moderado'
GROUP BY t.turno;

--EX3: lotação de infraestrutura no dia 01-01-2025 (infraestrutura utilizada/infraestrutura total)
WITH x AS (
	SELECT i.nome_hospital, i.categoria, count (id_infraestrutura) as infra_total
	FROM urgencia.dim_infraestruturas i
	WHERE i.data_entrada < '2025-01-01' AND (data_saida IS NULL OR data_saida >= '2025-01-01')
	GROUP BY i.nome_hospital,i.categoria
),
y as (
	SELECT i.nome_hospital,i.categoria, count (distinct i.id_infraestrutura) as infra_em_utilização 
	FROM urgencia.dim_infraestruturas i
	JOIN urgencia.dim_infra_ocup io
	ON i.id_infraestrutura = io.id_infraestrutura
	WHERE io.tempo_inicio < '2025-01-01 23:59:59' and io.tempo_fim > '2025-01-01 00:00:00'
	GROUP BY i.nome_hospital,i.categoria
)
SELECT y.*, x.infra_total,round(y.infra_em_utilização/x.infra_total::numeric,2) as lotação 
FROM y
JOIN x
ON x.nome_hospital = y.nome_hospital
AND x.categoria = y.categoria; 





