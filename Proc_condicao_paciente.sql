
/*
==================================================================================================
Data:            02/10/2024
Autor:           Fabiana Pacheco
Descrição:       Criação da procedure [SP_CARGA_TBL_CONDICAO_PACIENTE]
Solicitado por:  Chamado 111447
Propósito:       Carga diária para a tabela TBL_CONDICAO_PACIENTE
Observação:      
Job:             07 - DW - XXXXXX - SP_CARGA_TBL_CONDICAO_PACIENTE
Step:            Carga Diária
Command:         Carga

==================================================================================================
*/

-- EXEC SP_CARGA_TBL_CONDICAO_PACIENTE

/*
CREATE TABLE TBL_CONDICAO_PACIENTE(

[ATENDIMENTO_ID] VARCHAR(100) NULL,
[PAC_NOME] VARCHAR (200) NULL,
[DT_NASC_RECENTE] VARCHAR (100) NULL,
[IDENTIFICACAO_PACIENTE] VARCHAR (100) NULL,
[IDADE] INT,
[FAIXA_ETARIA] VARCHAR (100) NULL,
[CID] VARCHAR (100)NULL,
[CIAP] VARCHAR (100) NULL, 
[CONDICAO] VARCHAR (100) NULL, 
[CEP_PACIENTE] VARCHAR (100) NULL, 
[NOME_UNIDADE] VARCHAR (200) NULL,
[CEP_UNIDADE] VARCHAR (100) NULL, 
[DT_ULTIMA_ATUALIZACAO] DATETIME)

*/

ALTER PROCEDURE [dbo].[SP_Carga_TBL_CONDICAO_PACIENTE]
AS
BEGIN
    -- Limpar a tabela de destino
    TRUNCATE TABLE TBL_CONDICAO_PACIENTE;

    -- Insere dados na tabela
   WITH CTE AS (
    SELECT
        atend.AtendimentoId,
        p.pac_nome,
        MAX(p.pac_nascimento) AS DataNascimentoRecente,
         COALESCE(NULLIF(p.PAC_CPF, ''), p.PAC_CARTAO_NSAUDE) AS IdentificacaoPaciente,
        DATEDIFF(YEAR, MAX(p.pac_nascimento), GETDATE()) AS Idade,
        CASE
            WHEN DATEDIFF(YEAR, MAX(p.pac_nascimento), GETDATE()) < 6 THEN 'Menores de 6 anos'
            WHEN DATEDIFF(YEAR, MAX(p.pac_nascimento), GETDATE()) > 60 THEN 'Maiores de 60 anos'
            ELSE 'Entre 6 e 60 anos'
        END AS FaixaEtaria,
        c.co_cid, ci.CIAP_Codigo,
        CASE
            -- Condição para Gestante
            WHEN (ci.CIAP_Codigo IN ('W03', 'W05', 'W29', 'W71', 'W72', 'W73', 'W76', 'W78', 'W79', 'W80', 'W81', 'W84', 'W85')
                OR c.co_cid IN ('O00', 'O10', 'O20', 'O30', 'O35', 'O40', 'O752', 'Z321', 'O000', 'O11', 'O200', 'O300', 'O350', 'O41',
                             'O753', 'Z33', 'O001', 'O12', 'O208', 'O301', 'O351', 'O410', 'O98', 'Z34', 'O002', 'O120', 'O209',
                             'O302', 'O352', 'O411', 'O990', 'Z340', 'O008', 'O121', 'O21', 'O308', 'O353', 'O418', 'O991',
                             'Z348', 'O009', 'O122', 'O210', 'O309', 'O354', 'O419', 'O992', 'Z349', 'O13', 'O211', 'O31',
                             'O355', 'O43', 'O993', 'Z35', 'O14', 'O212', 'O311', 'O356', 'O430', 'O994', 'Z350', 'O140',
                             'O218', 'O312', 'O357', 'O431', 'O995', 'Z351', 'O141', 'O219', 'O318', 'O358', 'O438', 'O996',
                             'Z352', 'O149', 'O22', 'O32', 'O359', 'O439', 'O997', 'Z353', 'O15', 'O220', 'O320', 'O36',
                             'O44', 'Z354', 'O150', 'O221', 'O321', 'O360', 'O440', 'Z357', 'O151', 'O222', 'O322', 'O361',
                             'O441', 'Z358', 'O159', 'O223', 'O323', 'O362', 'O46', 'Z359', 'O16', 'O224', 'O324', 'O363',
                             'O460', 'Z36', 'O225', 'O325', 'O365', 'O468', 'Z640', 'O228', 'O326', 'O366', 'O469', 'O229',
                             'O328', 'O367', 'O47', 'O23', 'O329', 'O368', 'O470', 'O230', 'O33', 'O369', 'O471', 'O231',
                             'O330', 'O479', 'O232', 'O331', 'O48', 'O233', 'O332', 'O234', 'O333', 'O235', 'O334', 'O239',
                             'O335', 'O24', 'O336', 'O240', 'O337', 'O241', 'O338', 'O242', 'O339', 'O243', 'O34', 'O244',
                             'O340', 'O249', 'O341', 'O25', 'O342', 'O26', 'O343', 'O260', 'O344', 'O261', 'O345', 'O263',
                             'O346', 'O264', 'O347', 'O265', 'O348', 'O268', 'O349', 'O269', 'O28', 'O280', 'O281', 'O282',
                             'O283', 'O284', 'O285', 'O288', 'O289', 'O29', 'O290', 'O291', 'O292', 'O293', 'O294', 'O295',
                             'O296', 'O298', 'O299'))  and PB.situacao ='Ativo' and PB.TipoProblema = 'Diagnóstico Definitivo'
            THEN 'Gestante'
            -- Condição para Hipertensão
            WHEN ci.CIAP_Codigo IN ('K86', 'K87')
                OR c.co_cid IN ('I10', 'O10', 'I11', 'O100', 'I110', 'O101', 'I119', 'O102', 'I12', 'O103', 'I120', 'O104',
                             'I129', 'O109', 'I13', 'O11', 'I130', 'I131', 'I132', 'I139', 'I15', 'I150', 'I151',
                             'I152', 'I158', 'I159')
            THEN 'Hipertensão'
            -- Condição para Diabetes
            WHEN ci.CIAP_Codigo IN ('T89', 'T90')
                OR c.co_cid IN ('E10', 'E11', 'E12', 'E13', 'E14', 'O240', 'E100', 'E110', 'E120', 'E130', 'E140', 'O241',
                             'E101', 'E111', 'E121', 'E131', 'E141', 'O242', 'E102', 'E112', 'E122', 'E132', 'E142',
                             'O243', 'E103', 'E113', 'E123', 'E133', 'E143', 'E104', 'E114', 'E124', 'E134', 'E144',
                             'E105', 'E115', 'E125', 'E135', 'E145', 'E106', 'E116', 'E126', 'E136', 'E146', 'E107',
                             'E117', 'E127', 'E137', 'E147', 'E108', 'E118', 'E128', 'E138', 'E148', 'E109', 'E119',
                             'E129', 'E139', 'E149')
            THEN 'Diabetes'
            -- Condição padrão
            ELSE 'Outro'
        END AS Condicao,
        b1.cep AS cep_paciente,
        a.Unid_nome_fantasia,
        b.cep AS cep_unidade,
        ROW_NUMBER() OVER (PARTITION BY atend.AtendimentoId,
            CASE
                -- Reaplicamos a lógica da condição aqui
                WHEN (ci.CIAP_Codigo IN ('W03', 'W05', 'W29', 'W71', 'W72', 'W73', 'W76', 'W78', 'W79', 'W80', 'W81', 'W84', 'W85')
                    OR c.co_cid IN ('O00', 'O10', 'O20', 'O30', 'O35', 'O40', 'O752', 'Z321', 'O000', 'O11', 'O200', 'O300', 'O350', 'O41',
                             'O753', 'Z33', 'O001', 'O12', 'O208', 'O301', 'O351', 'O410', 'O98', 'Z34', 'O002', 'O120', 'O209',
                             'O302', 'O352', 'O411', 'O990', 'Z340', 'O008', 'O121', 'O21', 'O308', 'O353', 'O418', 'O991',
                             'Z348', 'O009', 'O122', 'O210', 'O309', 'O354', 'O419', 'O992', 'Z349', 'O13', 'O211', 'O31',
                             'O355', 'O43', 'O993', 'Z35', 'O14', 'O212', 'O311', 'O356', 'O430', 'O994', 'Z350', 'O140',
                             'O218', 'O312', 'O357', 'O431', 'O995', 'Z351', 'O141', 'O219', 'O318', 'O358', 'O438', 'O996',
                             'Z352', 'O149', 'O22', 'O32', 'O359', 'O439', 'O997', 'Z353', 'O15', 'O220', 'O320', 'O36',
                             'O44', 'Z354', 'O150', 'O221', 'O321', 'O360', 'O440', 'Z357', 'O151', 'O222', 'O322', 'O361',
                             'O441', 'Z358', 'O159', 'O223', 'O323', 'O362', 'O46', 'Z359', 'O16', 'O224', 'O324', 'O363',
                             'O460', 'Z36', 'O225', 'O325', 'O365', 'O468', 'Z640', 'O228', 'O326', 'O366', 'O469', 'O229',
                             'O328', 'O367', 'O47', 'O23', 'O329', 'O368', 'O470', 'O230', 'O33', 'O369', 'O471', 'O231',
                             'O330', 'O479', 'O232', 'O331', 'O48', 'O233', 'O332', 'O234', 'O333', 'O235', 'O334', 'O239',
                             'O335', 'O24', 'O336', 'O240', 'O337', 'O241', 'O338', 'O242', 'O339', 'O243', 'O34', 'O244',
                             'O340', 'O249', 'O341', 'O25', 'O342', 'O26', 'O343', 'O260', 'O344', 'O261', 'O345', 'O263',
                             'O346', 'O264', 'O347', 'O265', 'O348', 'O268', 'O349', 'O269', 'O28', 'O280', 'O281', 'O282',
                             'O283', 'O284', 'O285', 'O288', 'O289', 'O29', 'O290', 'O291', 'O292', 'O293', 'O294', 'O295',
                             'O296', 'O298', 'O299'))  and PB.situacao ='Ativo' and PB.TipoProblema = 'Diagnóstico Definitivo'
                THEN 'Gestante'
                WHEN ci.CIAP_Codigo IN ('K86', 'K87')
                    OR c.co_cid IN ('I10', 'O10', 'I11', 'O100', 'I110', 'O101', 'I119', 'O102', 'I12', 'O103', 'I120', 'O104',
                             'I129', 'O109', 'I13', 'O11', 'I130', 'I131', 'I132', 'I139', 'I15', 'I150', 'I151',
                             'I152', 'I158', 'I159')
                THEN 'Hipertensão'
                WHEN ci.CIAP_Codigo IN ('T89', 'T90')
                    OR c.co_cid IN ('E10', 'E11', 'E12', 'E13', 'E14', 'O240', 'E100', 'E110', 'E120', 'E130', 'E140', 'O241',
                             'E101', 'E111', 'E121', 'E131', 'E141', 'O242', 'E102', 'E112', 'E122', 'E132', 'E142',
                             'O243', 'E103', 'E113', 'E123', 'E133', 'E143', 'E104', 'E114', 'E124', 'E134', 'E144',
                             'E105', 'E115', 'E125', 'E135', 'E145', 'E106', 'E116', 'E126', 'E136', 'E146', 'E107',
                             'E117', 'E127', 'E137', 'E147', 'E108', 'E118', 'E128', 'E138', 'E148', 'E109', 'E119',
                             'E129', 'E139', 'E149')
                THEN 'Diabetes'
                ELSE 'Outro'
            END
        ORDER BY atend.AtendimentoId) AS rn -- Numerando cada linha para o mesmo AtendimentoId e Condicao
    FROM
        LINKED_SERVER.dbo.paciente p
    JOIN
        LINKED_SERVER.dbo.Atendimento atend ON p.PacienteId = atend.PacienteId
    join LINKED_SERVER.dbo.equipe e on e.EquipeId = p.EquipeId
    JOIN
        LINKED_SERVER.dbo.UNIDADE a ON p.UnidadeId = a.unidadeid
    JOIN
        LINKED_SERVER.dbo.Endereco b ON a.EnderecoId = b.EnderecoId
    JOIN
        LINKED_SERVER.dbo.Endereco b1 ON b1.EnderecoId = p.EnderecoId
    LEFT JOIN
        LINKED_SERVER.dbo.PROBLEMAATENDIMENTO PA WITH (NOLOCK) ON ATend.ATENDIMENTOID = PA.ATENDIMENTOID
    LEFT JOIN
        LINKED_SERVER.dbo.PROBLEMA PB WITH (NOLOCK) ON PA.PROBLEMAID = PB.PROBLEMAID
    LEFT JOIN
        LINKED_SERVER.dbo.CIAP_2 CI WITH (NOLOCK) ON PB.CIAP_CODIGO = CI.CIAP_CODIGO
    LEFT JOIN
        LINKED_SERVER.dbo.TB_CID C WITH (NOLOCK) ON PB.CO_CID = C.CO_CID
    WHERE
        b1.municipio like '%merit%'
    GROUP BY
        atend.AtendimentoId,
        p.pac_nome,
        c.co_cid,
        ci.CIAP_Codigo,
        b1.cep,
        a.Unid_nome_fantasia,
        b.cep,
        p.PAC_CPF, 
		p.PAC_CARTAO_NSAUDE,
		PB.situacao,
		PB.TipoProblema
   /* HAVING
        DATEDIFF(YEAR, MAX(p.pac_nascimento), GETDATE()) < 6
        OR DATEDIFF(YEAR, MAX(p.pac_nascimento), GETDATE()) > 60*/
)
    
    -- Inserindo registros únicos na tabela
   INSERT INTO TBL_CONDICAO_PACIENTE (
  [ATENDIMENTO_ID], [PAC_NOME], [DT_NASC_RECENTE], [IDENTIFICACAO_PACIENTE],
        [IDADE], [FAIXA_ETARIA], [CID], [CIAP], [CONDICAO],
        [CEP_PACIENTE], [NOME_UNIDADE], [CEP_UNIDADE],
    DT_ULTIMA_ATUALIZACAO 
)
SELECT
    AtendimentoId,
    pac_nome,
    DataNascimentoRecente,
    IdentificacaoPaciente,
    Idade,
    FaixaEtaria,
    co_cid,
    CIAP_Codigo,
    Condicao,
    cep_paciente,
    Unid_nome_fantasia,
    cep_unidade,
    GETDATE() 
FROM
    CTE
WHERE
    rn = 1;

END
