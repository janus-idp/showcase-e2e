before(() => {
  cy.clearAllCookies();
  cy.clearAllLocalStorage();
    clearAllStorageIdexDB();
});

function clearAllStorageIdexDB() {
    cy.log('Begin by clearing all web stored data.');
    cy.window().then(async (win) => {
        const databases = await win.indexedDB.databases();
        await Promise.all(
            databases.map(
                ({name}) =>
                    new Promise((resolve, reject) => {
                        const request = window.indexedDB.deleteDatabase(name as string);

                        request.addEventListener('success', resolve);
                        request.addEventListener('blocked', resolve);
                        request.addEventListener('error', reject);
                    })
            )
        );
        win.localStorage.clear();
        win.sessionStorage.clear();
        win.document.cookie = '';
        cy.log('All web-stored data has been cleared!');
    });
}
