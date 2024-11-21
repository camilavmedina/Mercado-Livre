----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
---------------------------------------------------------------------------------- 
##################### DER - DIAGRAMA ENTIDADE- RELACIONAMENTO ####################
----------------------------------------------------------------------------------
----------O DESENHO DO DIAGRAMA SE ENCONTRA NO REPOSITÓRIO------------------------
---------------------------------------------------------------------------------- 
 CUSTOMER {
        INT ID_Customer PK
        VARCHAR email
        VARCHAR nome
        VARCHAR sobrenome
        CHAR sexo
        VARCHAR endereco
        DATE data_nascimento
        VARCHAR tipo_usuario
    }

    CATEGORY {
        INT ID_Category PK
        VARCHAR nome_categoria
        VARCHAR descricao_categoria
        VARCHAR path_categoria
    }

    ITEM {
        INT ID_Item PK
        VARCHAR nome_produto
        DECIMAL preco
        INT categoria_id FK
        VARCHAR estado
        DATE end_date
    }

    ORDERS {
        INT ID_Order PK
        INT ID_Customer FK
        INT ID_Item FK
        INT quantidade
        DECIMAL preco_total
        DATE data_pedido
        VARCHAR status_pedido
    }

-------------------------------------------------------------------------------------------------------------	
-------------------Explicação do Diagrama--------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
Tabela CUSTOMER:
Representa os clientes do sistema.
Possui os campos ID_Customer (chave primária), email, nome, sobrenome, sexo, endereco, data_nascimento e tipo_usuario.

Tabela CATEGORY:
Representa as categorias de produtos.
Possui ID_Category (chave primária), nome_categoria, descricao_categoria e path_categoria.
Tabela ITEM:

Representa os produtos no sistema.
Possui ID_Item (chave primária), nome_produto, preco, categoria_id (chave estrangeira que se relaciona com CATEGORY), 
estado (estado do produto, ativo ou inativo) e end_date (data de desativação).

Tabela ORDERS:
Representa os pedidos realizados pelos clientes.
Possui ID_Order (chave primária), 
ID_Customer (chave estrangeira que se relaciona com CUSTOMER), 
ID_Item (chave estrangeira que se relaciona com ITEM), 
quantidade (quantidade de itens), 
preco_total (preço total do pedido), 
data_pedido e 
status_pedido (estado do pedido).
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
######### Relacionamentos entre as tabelas:
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
Customer - Orders: Um cliente pode realizar vários pedidos. Relacionamento 1.
Item - Orders: Um pedido pode conter vários itens, mas um item pode estar presente em múltiplos pedidos. Relacionamento M
(devido à presença de quantidade no pedido).
Category - Item: Uma categoria pode ter vários itens (produtos), mas cada item pertence a uma única categoria. Relacionamento 1
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
---------------------------------------------------------------------------------- 
##### Abaixo segue os scripts DDL para as criações das tabelas no banco ##########
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

-- Tabela Customer
CREATE TABLE Customer (
    ID_Customer INT IDENTITY(1,1) PRIMARY KEY,   					-- garantir unicidade e auto incremento
    email VARCHAR(255) NOT NULL UNIQUE,           					-- Email único e não nulo
    nome VARCHAR(100),                            					-- Nome do cliente
    sobrenome VARCHAR(100),                       					-- Sobrenome do cliente
    sexo CHAR(1),                                 					-- Sexo (um único caractere, 'M' ou 'F')
    endereco VARCHAR(255),                        					-- Endereço do cliente
    data_nascimento DATE,                          					-- Data de nascimento
	tipo_usuario varchar(50)										-- Buyers or Sellers
);
----------------------------------------------------------------------------------

-- Tabela Category
CREATE TABLE Category (
    ID_Category INT IDENTITY(1,1) PRIMARY KEY,        				-- garantir unicidade e auto incremento
    nome_categoria VARCHAR(100) NOT NULL,              				-- Nome da categoria, não pode ser nulo
    descricao_categoria VARCHAR(1200),                          	-- Descrição da categoria
    path_categoria VARCHAR(255)                        				-- Caminho associado à categoria
);

----------------------------------------------------------------------------------

-- Tabela Item
CREATE TABLE Item (
    ID_Item INT IDENTITY(1,1) PRIMARY KEY,             			    -- garantir unicidade e auto incremento
    nome_produto VARCHAR(255) NOT NULL,                  			-- Nome do produto, não pode ser nulo
    preco DECIMAL(10,2) NOT NULL,                       			-- Preço do produto, não pode ser nulo
    categoria_id INT,                                    			-- ID da categoria associada ao produto
    estado VARCHAR(50),                                  			-- Estado do produto (Ativo, Inativo, Indisponível..)
    end_date DATE,                                       			-- Data de desativação do produto
    FOREIGN KEY (categoria_id) REFERENCES Category(ID_Category)  	-- Relacionamento com a tabela Category
);
----------------------------------------------------------------------------------

-- Tabela Orders
CREATE TABLE Orders (
    ID_Order INT IDENTITY(1,1) PRIMARY KEY,            				-- garantir unicidade e auto incremento
    ID_Customer INT,                                    			-- ID do cliente que fez o pedido
    ID_Item INT,                                        			-- ID do produto comprado
    quantidade INT NOT NULL,                             			-- Qtde de itens comprados
    preco_total DECIMAL(10,2) NOT NULL,                 			-- Preço total do pedido
    data_pedido DATE,                                    			-- Data do pedido
	status_pedido varchar(50),										-- Pendente/Processando/concluido
    FOREIGN KEY (ID_Customer) REFERENCES Customer(ID_Customer),   	-- Relacionamento com a tabela Customer
    FOREIGN KEY (ID_Item) REFERENCES Item(ID_Item)              	-- Relacionamento com a tabela Item
);
