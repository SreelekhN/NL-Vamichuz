NL is a network layer built on top of url session which can help you implement rest/graphql api calls

Usage:

import NL

protocol SearchClientProtocol {
    func search(searchText: String, curser: String) async -> FinalResponse<SearchDecodable>
}

struct SearchListClient: HTTPClient, SearchClientProtocol {
    func search(searchText: String, curser: String) async -> FinalResponse<SearchDecodable> {
        let compose = SearchCompose(searchText: searchText, curser: curser)
        return await self.serverRequest(compose: compose,
                                        decoder: SearchDecodable.self)
    }
}

Make ur class or struct conform to HTTPClient protocol, by which u can access its methods.

The compose parameter will take in all the input params.
to make this make a class/ struct that conforms to HttpsRequestComposeProtocol like below,

import NL

struct SearchCompose: HttpsRequestComposeProtocol {
    
    var method: NetworkMethod {
        return .post
    }
    
    var params: Encodable?
    
    init(searchText: String, curser: String) {
        self.createQuiry(searchText: searchText, curser: curser)
    }
    
    private mutating func createQuiry(searchText: String, curser: String) {
        var extra: String = """
          query: "\(searchText)", first: 20
        """
        if curser.isNotEmpty {
            extra +=
        """
        , after: "\(curser)"
        """
        }
        
        let query =
        """
query {
  search(\(extra)) {
        pageInfo {
        hasNextPage
        }
    edges {
cursor
      node {
      }
    }
  }
}
"""
        self.params = QuerySendable(query: query)
    }
}

here this is a graphql quiry, u can also pass params for regular rest api calls.

This is a work on progress, report any bug or features if u need
