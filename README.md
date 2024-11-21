Teste Mercado Livre
Projeto E-commerce Mercado Livre
Este projeto consiste em uma análise de um modelo de e-commerce utilizando SQL e APIs para responder a questões de negócios sobre a operação do marketplace. O sistema modelado consiste em clientes, pedidos, itens e categorias, com foco na criação de consultas SQL e integração com APIs para análise de dados.

####DER.png Com base no modelo de dados do projeto apresentado (Customer, Item, Category, Orders), foi criado um Diagrama de Entidade-Relacionamento (DER) para visualizar as entidades e os relacionamentos entre elas.

####SQL O objetivo principal é modelar o banco de dados para responder a questões sobre vendas e usuários utilizando consultas SQL.

Tabelas: Customer: Contém informações sobre os usuários (compradores e vendedores). Item: Representa os produtos vendidos no site. Category: Descrição das categorias de produtos. Order: Registra as compras realizadas pelos usuários.

Consultas SQL:

Consulta para listar os aniversariantes do dia e vendas em Janeiro/2020.
Top 5 vendedores por mês em 2020 na categoria de Celulares.
Processamento de dados para registrar o preço e estado atual dos itens.
####APIs Analisar as ofertas de produtos no Mercado Livre utilizando APIs públicas. Realizar buscas de produtos, extrair informações detalhadas e exportar os resultados em formato CSV.

Processos: Busca por produtos: Realizar consultas sobre produtos (como "chromecast", "Google Home", etc.). Consulta de detalhes dos produtos: Para cada produto, realizar uma consulta detalhada utilizando o item_id. Exportação de dados: Desnormalizar os dados e exportá-los para um arquivo CSV.