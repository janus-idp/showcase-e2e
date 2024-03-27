import {Common} from "../../../utils/Common";
import {UIhelper} from "../../../utils/UIhelper";

describe('Catalog page', () => {
    before(() => {
        Common.loginAsGuest();
    });

    beforeEach(() => {
        UIhelper.openSidebar('Catalog');
    });

    const filterAndVerify = (kind, expectedRows) => {
        UIhelper.selectMuiBox('Kind', kind);
        UIhelper.verifyRowsInTable(expectedRows);
    };

    it('should filter by Location successfully', () => {
        filterAndVerify('Location', ['dynamic-plugins-test-templates-location']);
    });

    it('should filter by Template successfully', () => {
        filterAndVerify('Template', ['Get Browser Event Sink Tool URL']);
    });

});
