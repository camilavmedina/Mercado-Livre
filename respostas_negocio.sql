----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
################################################## PARA RESOLVER #######################################################################
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
1. Listar os usuários que fazem aniversário no dia de hoje e que a quantidade de vendas realizadas em Janeiro/2020 seja superior a 1500

SELECT 
    a.ID_Customer, 
	a.nome, 
	a.sobrenome,
	a.data_nascimento, 
    sum(o.quantidade) as qtde_vendas
FROM 
    Customer a
JOIN 
    Orders o
	ON a.ID_Customer = o.ID_Customer
WHERE 
	MONTH(a.data_nascimento) = MONTH(GETDATE())  			-- Se precisar do mês corrente, descomentar a linha
	AND DAY(a.data_nascimento) = DAY(GETDATE())  			-- Se precisar do dia corrente, descomentar a linha
    AND o.data_pedido BETWEEN '2020-01-01' AND '2020-01-31'  	-- Vendas no período de jan/20
	and o.status_pedido = 'concluido'
GROUP BY 
    a.ID_Customer, 
	a.nome, 
	a.sobrenome,
	a.data_nascimento
HAVING sum(quantidade) > 1500;								-- Total de vendas maior que 1500
-----------------------------------------------------------------------------------------------------------------------
2. Para cada mês de 2020, exibir um top 5 dos usuários que mais venderam ($) na categoria Celulares

WITH month_sales_phone AS (
    SELECT 
		b.nome_categoria,
        YEAR(o.data_pedido) AS ano,
        MONTH(o.data_pedido) AS mes,
        c.nome,
        c.sobrenome,
        c.ID_Customer,
        COUNT(o.ID_Order) AS quantidade_vendas,
        SUM(o.quantidade) AS quantidade_produtos_vendidos,
        SUM(o.preco_total) AS total_vendido,
        ROW_NUMBER() OVER (PARTITION BY YEAR(o.data_pedido), MONTH(o.data_pedido) ORDER BY SUM(o.preco_total) DESC) AS rank
    FROM 
        Orders o
    INNER JOIN 
        Customer c 
		ON o.ID_Customer = c.ID_Customer
    INNER JOIN 
        Item i 
		ON o.ID_Item = i.ID_Item
    INNER JOIN 
        Category b 
		ON i.categoria_id = b.ID_Category
        WHERE 
    b.nome_categoria = 'tecnologia'	and b.descricao_categoria like '%celular%'			-- Somente Categoria Celulares
    and  o.data_pedido BETWEEN '2020-01-01' AND '2020-12-31'	-- Filtrar dados do ano de 2020
	and c.tipo_usuario = 'Sellers'								-- Filtra somente vendedores
    GROUP BY 
		b.nome_categoria,
        YEAR(o.data_pedido), 
        MONTH(o.data_pedido), 
        c.ID_Customer, 
        c.nome, 
        c.sobrenome
)
SELECT 
    ano,
    mes,
    nome,
    sobrenome,
    quantidade_vendas,
    quantidade_produtos_vendidos,
    total_vendido
FROM 
    month_sales_phone
WHERE 
    rank <= 5
ORDER BY 
    ano, 
    mes, 
    total_vendido DESC;
--------------------------------------------------------------------------------
3. Popular uma nova tabela com o preço e estado dos itens no final do dia

---Script da criação da tabela
CREATE TABLE preco_status_dia (
    ID_Item INT,
    data_registro DATE,
    preco DECIMAL(10,2),
    estado VARCHAR(10),
    PRIMARY KEY (ID_Item, data_registro),
    FOREIGN KEY (ID_Item) REFERENCES Item(ID_Item)
);

---- Criação da PRC -------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
---- Procedure irá inserir ou atualizar os registros na tabela preco_status_dia com base no preço e estado mais recente da tabela Item. 
---- Ela será capaz de reprocessar registros sem inserir duplicatas e deve ser performática em cenários com grandes volumes de dados.
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
create PROCEDURE SP_popular_preco_status_dia
AS
BEGIN
    -- Variáveis
    DECLARE @data_atual DATE = GETDATE();
    
    -- Remover registros antigos para o dia atual (caso precise de reprocessamento)
    -- Evitar duplicidade de registros para o mesmo dia e item
    DELETE FROM preco_status_dia 				-- remove todos os registros de preco_status_dia que possuem a mesma data_registro do dia atual
    WHERE data_registro = @data_atual;

    -- Usar MERGE para inserir ou atualizar os registros
    MERGE INTO preco_status_dia AS b
    USING (
        -- Seleciona os itens mais recentes da tabela Item
        SELECT i.ID_Item, i.preco, i.estado
        FROM Item i
        WHERE i.end_date IS NULL 
		OR i.end_date >= @data_atual 			-- Verifica se o item está ativo
    ) AS i
    ON b.ID_Item = i.ID_Item 
	AND b.data_registro = @data_atual
    WHEN MATCHED THEN
        -- Atualiza o preço e estado se o item e a data já existirem
        UPDATE SET 	b.preco = i.preco, 
					b.estado = i.estado
    WHEN NOT MATCHED THEN
        -- Insere se não houver um registro para o item no dia atual
        INSERT (ID_Item, data_registro, preco, estado)
        VALUES (i.ID_Item, @data_atual, i.preco, i.estado);     

END;

-- comando para executar a procedure
EXEC SP_popular_preco_status_dia



