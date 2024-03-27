import RequestBody = Cypress.RequestBody;
import RequestOptions = Cypress.RequestOptions;

export class RequestHelper {
    static request(options: Partial<RequestOptions>) {
        return cy.request({...options, failOnStatusCode: false})
    }

    static get(url: string, body?: RequestBody) {
        return RequestHelper.request({
            method: 'GET',
            url: url,
            body
        })
    }

    static post(url: string, body?: RequestBody) {
        return RequestHelper.request({
            method: 'POST',
            url: url,
            body
        })
    }

    static put(url: string, body?: RequestBody) {
        return RequestHelper.request({
            method: 'GET',
            url: url,
            body
        })
    }

    static patch(url: string, body?: RequestBody) {
        return RequestHelper.request({
            method: 'PATCH',
            url: url,
            body
        })
    }

    static delete(url: string, body?: RequestBody) {
        return RequestHelper.request({
            method: 'DELETE',
            url: url,
            body
        })
    }
}
