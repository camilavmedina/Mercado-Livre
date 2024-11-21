import requests
import pandas as pd
import time
#Essa funcao busca itens a partir de uma consulta (query), com paginacao, ate o numero maximo de itens definido (max_itens).
def buscar_itens(query, limit=50, max_itens=150):  # A funcao recebe uma consulta (query), limite de itens por pagina (limit) e o maximo de itens (max_itens)
    print(f"Buscando itens para: {query}")  # Exibe o termo da pesquisa no console para o usuario saber o que esta sendo buscado
    itens = []  # Lista para armazenar os itens encontrados
    offset = 0  # Inicia o offset da busca (usado para paginar os resultados)
    contexto_pesquisa = {}  # Dicionario para armazenar dados do contexto da pesquisa (informacoes como site_id, filtros, etc.)
    
    # Loop para buscar itens enquanto o numero de itens encontrados for menor que max_itens
    while len(itens) < max_itens:
        # Monta a URL da requisicao com o termo de busca, limite e offset
        url = f"https://api.mercadolibre.com/sites/MLA/search?q={query}&limit={limit}&offset={offset}"
        try:
            response = requests.get(url)  # Realiza a requisicao GET a API
            response.raise_for_status()  # Levanta uma excecao se o código de status HTTP nao for 200 (OK)
            dados = response.json()  # Converte a resposta JSON em um dicionario Python

            # Captura dados adicionais de contexto da pesquisa
            contexto_pesquisa['site_id'] = dados.get('site_id', '')
            contexto_pesquisa['country_default_time_zone'] = dados.get('country_default_time_zone', '')
            contexto_pesquisa['query'] = dados.get('query', '')
            contexto_pesquisa['paging'] = dados.get('paging', {})
            contexto_pesquisa['sort'] = dados.get('sort', {})
            contexto_pesquisa['available_sorts'] = dados.get('available_sorts', [])
            contexto_pesquisa['filters'] = dados.get('filters', [])
            contexto_pesquisa['available_filters'] = dados.get('available_filters', [])
            contexto_pesquisa['pdp_tracking'] = dados.get('pdp_tracking', {})
            contexto_pesquisa['user_context'] = dados.get('user_context', None)

            novos_itens = dados.get('results', [])  # Lista de itens encontrados na pagina
            itens.extend(novos_itens)  # Adiciona os novos itens a lista de itens
            print(f"Encontrados {len(novos_itens)} itens para: {query} na pagina com offset {offset}")
            
            if len(itens) >= max_itens:  # Se ja tiver encontrado o numero maximo de itens, encerra o loop
                break
            
            # Atualiza o offset para a próxima pagina de resultados
            offset += limit
        except requests.exceptions.RequestException as e:  # Caso ocorra algum erro durante a requisicao, captura a excecao
            print(f"Erro ao buscar itens para: {query} - {e}")  # Exibe o erro no console
            break  # Encerra o loop em caso de erro na requisicao
    
    print(f"Total de itens encontrados: {len(itens)} para: {query}")  # Exibe o total de itens encontrados
    return itens, contexto_pesquisa  # Retorna a lista de itens encontrados e os dados do contexto da pesquisa
#A funcao busca os itens na API de forma paginada. A cada pagina, ela faz uma requisicao com offset que vai sendo incrementado conforme novas paginas sao carregadas.
#Ela continua buscando itens ate atingir o maximo (max_itens) ou ate que nao haja mais resultados.
#Os dados de contexto, como filtros e informacoes de paginacao, sao armazenados em contexto_pesquisa.
#Funcao obter_detalhes_item obtem os detalhes de um item especifico usando seu item_id.
def obter_detalhes_item(item_id):  # Recebe o ID do item para buscar os detalhes
    print(f"Obtendo detalhes para o item: {item_id}")  # Exibe o ID do item no console
    url = f"https://api.mercadolibre.com/items/{item_id}"  # Monta a URL da requisicao para obter os detalhes do item
    try:
        response = requests.get(url)  # Faz a requisicao GET para obter os detalhes do item
        response.raise_for_status()  # Levanta excecao se o status nao for 200
        return response.json()  # Retorna os dados do item em formato JSON
    except requests.exceptions.RequestException as e:  # Caso ocorra um erro, captura a excecao
        print(f"Erro ao obter detalhes para o item: {item_id} - {e}")  # Exibe o erro
        return {}  # Retorna um dicionario vazio se ocorrer erro
#Funcao obter_detalhes_item recebe o ID de um item e faz uma requisicao para obter detalhes desse item.
#Se a requisicao for bem-sucedida, ela retorna os dados do item.
#Caso ocorra algum erro, ela captura a excecao e retorna um dicionario vazio.
#Funcao desnormalizar_item "desnormaliza" os dados de um item, ou seja, converte o JSON do item em um formato mais simples, util para analise posterior.
def desnormalizar_item(item, contexto_pesquisa):  # Recebe os dados do item e do contexto de pesquisa
    dados_item = {  # Cria um dicionario com os campos de interesse do item
        'Item_id': item.get('id', ''),  # ID do item
        'Title': item.get('title', ''),  # Titulo do item
        'Price': item.get('price', ''),  # Preco do item
        'Currency_id': item.get('currency_id', ''),  # ID da moeda
        'Available_quantity': item.get('available_quantity', ''),  # Quantidade disponivel
        'Condition': item.get('condition', ''),  # Condicao do item (novo, usado, etc.)
        'Category_id': item.get('category_id', ''),  # ID da categoria
        'Sold_quantity': item.get('sold_quantity', ''),  # Quantidade vendida
    }

    # Informacoes do vendedor (seller)
    seller = item.get('seller', {})  # Obtem as informacoes do vendedor, se existirem
    dados_item['Seller_id'] = seller.get('id', '')  # ID do vendedor
    dados_item['Seller_nickname'] = seller.get('nickname', '')  # Apelido do vendedor
    dados_item['Seller_reputation'] = seller.get('reputation', {}).get('level_id', '')  # Reputacao do vendedor

    # Atributos do item (ex.: cor, tamanho, etc.)
    atributos = item.get('attributes', [])  # Obtem os atributos, se existirem
    for i, atributo in enumerate(atributos, 1):  # Para cada atributo, adiciona ao dicionario
        dados_item[f'Attribute_{i}_Name'] = atributo.get('name', '')
        dados_item[f'Attribute_{i}_Value'] = atributo.get('value_name', '')

    # Primeira imagem do item (se houver)
    imagens = item.get('pictures', [])  # Obtem a lista de imagens
    dados_item['Image_URL'] = imagens[0]['url'] if imagens else ''  # URL da primeira imagem

    # Dados adicionais do contexto de pesquisa
    dados_item['Site_id'] = contexto_pesquisa.get('site_id', '')
    dados_item['Country_default_time_zone'] = contexto_pesquisa.get('country_default_time_zone', '')
    dados_item['Query'] = contexto_pesquisa.get('query', '')
    dados_item['Paging'] = contexto_pesquisa.get('paging', {})
    dados_item['Sort'] = contexto_pesquisa.get('sort', {})

    return dados_item  # Retorna o dicionario "desnormalizado"
	
#Funcao main é a principal que controla o fluxo de execucao do programa.
def main():
    termos_busca = ["chromecast", "Google Home", "Apple TV", "Amazon Fire TV"]  # Lista de termos de busca
    todos_itens = []  # Lista para armazenar todos os itens encontrados

    # Loop para buscar itens para cada termo
    for termo in termos_busca:
        itens, contexto_pesquisa = buscar_itens(termo, limit=50, max_itens=150)  # Busca ate 150 itens para cada termo
        for item in itens:
            item_id = item["id"]  # Obtem o ID do item
            detalhes_item = obter_detalhes_item(item_id)  # Obtem os detalhes do item
            if detalhes_item:  # Se os detalhes foram encontrados, desnormaliza
                dados_item = desnormalizar_item(detalhes_item, contexto_pesquisa)
                todos_itens.append(dados_item)  # Adiciona os dados desnormalizados a lista de todos os itens

            time.sleep(1)  # Pausa de 1 segundo entre as requisicoes para evitar sobrecarga no servidor

    # Converte os resultados em um DataFrame
    print("Convertendo resultados para DataFrame")
    df = pd.DataFrame(todos_itens)  # Converte a lista de itens para um DataFrame do pandas
    df.to_csv("resultado.csv", index=False, sep=",")  # Salva o DataFrame em um arquivo CSV
    print("Dados salvos em resultado.csv")
if __name__ == "__main__":
    main()
#os dados sao convertidos para um DataFrame e exportados para um arquivo CSV.