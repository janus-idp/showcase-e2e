import {Common} from "../../../utils/Common";
import {RequestHelper} from "../../../utils/RequestHelper";

describe('API Request', () => {
    before(() => {
        Common.loginAsGuest();
    });

    it('should api/catalog/locations API return 200 and empty data', () => {
        RequestHelper.get('http://localhost:7007/api/catalog/locations').then((response: {
            status: any;
            body: any;
        }) => {
            expect(response.status).to.equal(200);
            expect(response.body).to.deep.equal([]);
        });
    })

    it('should api/events/http/test-dynamic-plugins API return 200', () => {
        RequestHelper.post('http://localhost:7007/api/events/http/test-dynamic-plugins').then((response: {
            status: any;
            body: any;
        }) => {
            expect(response.status).to.equal(202);
            expect(response.body).to.deep.equal({
                "status": "accepted"
            });
        });
    })

    it('should api/explore/tools API return 200', () => {
        RequestHelper.get('http://localhost:7007/api/explore/tools').then((response: { status: any; }) => {
            expect(response.status).to.equal(200);
            // TODO: Do we need to verify the response body with complex data?
            // expect(response.body).to.deep.equal({
            //   "tools": [
            //     ...
            //   ]
            // });
        });
    })

});
