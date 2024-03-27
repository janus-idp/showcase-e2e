import {Common} from "../../../utils/Common";
import {UIhelper} from "../../../utils/UIhelper";
import {UIhelperPO} from "../../../support/pageObjects/global-obj";

describe('Create page', () => {
    before(() => {
        Common.loginAsGuest();
    });

    beforeEach(() => {
        UIhelper.openSidebar('Create');
    })

    it('should go to create page and choose list explore tools service', () => {
        UIhelper.clickButtonFromNthChild(UIhelperPO.MuiPaper, 1, 'Choose');
        UIhelper.selectMuiBox('Tag', 'dev');
        UIhelper.clickButton('Next step');
        UIhelper.clickButton('Create');
        UIhelper.verifyHeading('backstage request');
    })

    it('should go to create page and choose Get Browser Event Sink Tool URL service', () => {
        UIhelper.clickButtonFromNthChild(UIhelperPO.MuiPaper, 2, 'Choose');
        Common.waitForLoad();
        UIhelper.clickButton('Create');
        UIhelper.verifyText(UIhelperPO.MuiBox, 'Finished step backstage request');
    })
});
