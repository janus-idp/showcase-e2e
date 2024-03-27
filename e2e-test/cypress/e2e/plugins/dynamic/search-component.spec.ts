import {Common} from "../../../utils/Common";
import {UIhelper} from "../../../utils/UIhelper";
import {UIhelperPO} from "../../../support/pageObjects/global-obj";

describe('Search', () => {
    before(() => {
        Common.loginAsGuest();
    });

    it('should search list return results successfully', () => {
        UIhelper.clickButton('Search');
        UIhelper.verifyRowsInTable(['Browser Event Sink'], UIhelperPO.MuiListItem);
        UIhelper.clickButtonByAriaLabel('close');
    })

});
