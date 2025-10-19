import * as vscode from "vscode";

export function activate(context: vscode.ExtensionContext) {
  let disposable = vscode.commands.registerCommand(
    "vscode-open-folder-new-tab.openFolderNewTab",
    async (uri: vscode.Uri) => {
      if (!uri) {
        vscode.window.showErrorMessage("No folder selected");
        return;
      }

      try {
        // Get the current VS Code server URL
        const currentUrl = await vscode.env.asExternalUri(
          vscode.Uri.parse(vscode.env.uriScheme + "://" + vscode.env.appName)
        );

        // Get the absolute path of the selected folder
        const folderPath = uri.fsPath;

        // Construct the new URL with the folder parameter
        const newUrl = `${currentUrl.scheme}://${currentUrl.authority}${
          currentUrl.path
        }?folder=${encodeURIComponent(folderPath)}`;

        // Open in new browser tab
        await vscode.env.openExternal(vscode.Uri.parse(newUrl));

        // Also show the URL in a message for easy copying
        vscode.window.showInformationMessage(
          `Opened folder in new tab: ${folderPath}`
        );
      } catch (error) {
        vscode.window.showErrorMessage(
          `Failed to open folder in new tab: ${error}`
        );
      }
    }
  );

  context.subscriptions.push(disposable);
}

export function deactivate() {}
