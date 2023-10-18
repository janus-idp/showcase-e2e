import {CatalogUsersPO} from "../../../support/pageObjects/catalog/catalog-users-obj";
import Keycloak from "../../../utils/keycloak/keycloak";
import User from "../../../utils/keycloak/user";
import Group from "../../../utils/keycloak/group";
import {UIhelper} from "../../../utils/UIhelper";

let keycloak: Keycloak;

describe("Test Keycloak plugin", () => {
    before(() => {
        keycloak = new Keycloak();
        CatalogUsersPO.visitBaseURL();
        loginAsGuest();
    });
    it('Users on keycloak should match users on backstage', () => {
        keycloak.getAuthenticationToken().then((token) => {
            const backStageUsersFound = [];

            keycloak.getUsers(token).then((keycloakUsers: User[]) => {
                CatalogUsersPO.getListOfUsers().then((backStageUsers) => {
                    backStageUsers.each((index, backStageUser) => {
                        const userFound = keycloakUsers.find(user => user.username === backStageUser.textContent);
                        if(userFound) {
                            backStageUsersFound.push(userFound);
                        }
                    });

                    expect(keycloakUsers.length).to.eq(backStageUsersFound.length);

                    backStageUsersFound.forEach((backStageUser, index) => {
                        checkUserDetails(keycloakUsers[index], backStageUser, token);
                    });
                });
            });
        });

    })

    /**
     * If it's the first time logging in, the user will be prompted to login as guest
     * If not, the user will be logged in automatically
     */
    const loginAsGuest = () => {
        UIhelper.isHeaderTitleExists('Select a sign-in method').then((isHeaderTitleExists) => {
            if(isHeaderTitleExists) {
                UIhelper.clickButton('Enter');
            }
        });
    };

    const checkUserDetails = (keycloakUser, backStageUser, token) => {
        CatalogUsersPO.visitUserPage(keycloakUser.username);
        CatalogUsersPO.getEmailLink().should('be.visible');
        UIhelper.verifyDivHasText(`${keycloakUser.firstName} ${keycloakUser.lastName}`);

        keycloak.getGroupsOfUser(token, keycloakUser.id).then((groups: Group[]) => {
            groups.forEach((group) => {
                CatalogUsersPO.getGroupLink(group.name).should('be.visible');
            });
        });

        CatalogUsersPO.visitBaseURL();
    };
});
