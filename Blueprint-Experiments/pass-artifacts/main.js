require(['vs/editor/editor.main'], function () {
    require(['/js/editor/ts/quickOpenFile', '/js/editor/ts/explorer'], function (quickOpenFile, explorer) {
        // Terraform language syntax definition.
        monaco.languages.register({
            id: 'terraform',
            extensions: ['.tf'],
            aliases: ['Terraform', 'tf'],
        });
        monaco.languages.setLanguageConfiguration('terraform', {
            comments: {
                lineComment: '#',
            },
            brackets: [['{', '}'], ['[', ']'], ['(', ')']],
            autoClosingPairs: [
                { open: '{', close: '}' },
                { open: '[', close: ']' },
                { open: '(', close: ')' },
                { open: '"', close: '"' },
                { open: "'", close: "'" },
                { open: '`', close: '`' },
            ],
            surroundingPairs: [
                { open: '{', close: '}' },
                { open: '[', close: ']' },
                { open: '(', close: ')' },
                { open: '"', close: '"' },
                { open: "'", close: "'" },
                { open: '`', close: '`' },
            ],
        });
        monaco.languages.setMonarchTokensProvider('terraform', {
            defaultToken: '',
            ignoreCase: true,
            tokenPostfix: '.tf',

            brackets: [
                { token: 'delimiter.bracket', open: '{', close: '}' },
                { token: 'delimiter.parenthesis', open: '(', close: ')' },
                { token: 'delimiter.square', open: '[', close: ']' },
            ],

            builtins: [
                'abs', 'element', 'replace',
            ],

            keywords: [
                'true',
                'false',
                'terraform',
                'provider',
                'resource',
                'data',
                'variable',
                'output',
                'locals',
                'module',
            ],

            operators: [
                '=', '>', '<', '!', '~', '?', ':', '==', '<=', '>=', '!=',
                '&&', '||', '++', '--', '+', '-', '*', '/', '&', '|', '^', '%',
                '<<', '>>', '>>>', '+=', '-=', '*=', '/=', '&=', '|=', '^=',
                '%=', '<<=', '>>=', '>>>=',
            ],

            // References to locals, variables, output, resource, data, module,
            // and provider.
            references: /(\${)(([a-zA-Z-]\w*)(\.[a-zA-Z-]\w*)*)(})/,

            symbols: /[=><!~?&|+\-*\/\^;\.,]+/,

            tokenizer: {
                root: [
                    { include: '@whitespace' },

                    [
                        /[a-zA-Z-]\w*/,
                        {
                            cases: {
                                '@keywords': 'keyword',
                                '@default': 'key.identifier'
                            },
                        },
                    ],

                    { include: '@strings' },

                    [/[{}\[\]()]/, '@brackets'],

                    [
                        /@symbols/,
                        {
                            cases: {
                                '@operators': 'operator',
                                '@default': 'delimiter'
                            },
                        },
                    ],

                    { include: '@numbers' },
                ],

                whitespace: [
                    [/\s+/, 'white'],
                    [/\/\*/, 'comment', '@comment'],
                    [/#.*$/, 'comment'],
                ],

                comment: [
                    [/[^\/*]+/, 'comment'],
                    [/\/\*/, 'comment', '@push'],
                    ["\\*/", 'comment', '@pop'],
                    [/[\/*]/, 'comment']
                ],

                numbers: [
                    [/\d*\.\d+([eE][\-+]?\d+)?/, 'number.float'],
                    [/0[xX][0-9a-fA-F_]*[0-9a-fA-F]/, 'number.hex'],
                    [/\d+/, 'number'],
                ],

                strings: [
                    [/'/, 'string', '@stringBody'],
                    [/"/, 'string', '@dblStringBody']
                ],

                stringBody: [
                    [/'/, 'string', '@popall'],
                    ['@references', 'key.identifier'],
                    [/./, 'string'],
                ],

                dblStringBody: [
                    [/"/, 'string', '@popall'],
                    ['@references', 'key.identifier'],
                    [/./, 'string'],
                ],
            }
        });

        var editor = monaco.editor.create(document.getElementById('editor-container'), {
            theme: 'vs-dark'
        });
        var currentFileUri;
        var currentFileName;
        var currentFolderUri;
        var currentFileUnsaved;
        var currentFileVersion = editor.getModel().getAlternativeVersionId();

        enterClickHandler($("#editor-explorer-refresh-icon"), function () {
            explorer.refresh();
        });

        enterClickHandler($("#editor-error-quit"), function () {
            $("#editor-error-dialog").hide();
            $("#editor-dialog-back").hide();
            editor.focus();
        });

        document.addEventListener('show', function (e) {
            var detail = e.detail;
            var show = detail === 'editor' || (detail && detail.component === 'editor');
            if (!show) {
                $("#editor-wrapper").hide();
                if (currentFileUnsaved) {
                    currentFileUri = null;
                    currentFileName = null;
                    currentFolderUri = null;
                    currentFileUnsaved = null;
                }
            }
            if (show) {
                $("#editor-wrapper").show();
                logger.clientTelemetry('ACC.EDITOR.OPEN', {}, {}, Date.now() - term.connectTime.getTime());
                $("#terminal-open-editor").attr("editor-open", "true");
                $("#editor-terminal-separator").show();
                disableEditorOpen();
                if (detail.arguments && detail.arguments.isUnsavedFile && detail.arguments.fileUri) {
                    displayFile(detail.arguments.fileName, detail.arguments.fileUri, "", true);
                    explorer.refresh();
                } else if (detail.arguments && detail.arguments.fileUri) {
                    loadFile(detail.arguments);
                    explorer.refresh();
                } else if (detail.arguments && detail.arguments.folderUri) {
                    const folderUri = detail.arguments.folderUri;
                    quickOpenFile.setCurrentFolder(folderUri);
                    $("#explorer-wrapper").show();
                    $("#editor-explorer").show();
                    explorer.show(folderUri);
                    $(".monaco-tree").attr("aria-label", $("#editor-explorer-header-label").text().trim());
                    explorer.refresh();
                    currentFolderUri = folderUri;
                    if (currentFileUri && currentFileName) {
                        loadFile({ fileUri: currentFileUri, fileName: currentFileName }, true, true);
                    } else {
                        displayFile("Untitled", undefined, "", true);
                    }
                    editor.focus();
                } else {
                    editor.focus();
                }
            }
            document.dispatchEvent(new CustomEvent('layoutUpdate'));
        });

        document.addEventListener('layoutUpdate', function () {
            explorer.layout();
            editor.layout();
        });

        function closeEditor() {
            $("#terminal-open-editor").attr("editor-open", "false");
            $("#editor-terminal-separator").hide();
            enableEditorOpen();
            $("#editor-save-dialog").hide();
            $("#editor-dialog-back").hide();
            $("#terminal-container").height($("#terminal-and-editor").height());
            document.dispatchEvent(new CustomEvent('show', { detail: 'noeditor' }));
            logger.clientTelemetry('ACC.EDITOR.CLOSE', {}, {}, Date.now() - term.connectTime.getTime());
            term.focus();
        }

        enterClickHandler($("#hide-editor"), function (e) {
            hideEditorMenu();
            if (!fileIsDirty()) {
                closeEditor();
            }
            else {
                $("#editor-dialog-back").show();
                $("#editor-save-head").text($("#editor-save-head").attr("close-editor-text"));
                $("#editor-save-body").text($("#editor-save-body").attr("unsaved-file-warning"));
                $("#editor-save-input-entry").hide();
                $("#editor-save-dialog-buttons").removeClass("with-input");
                $("#editor-save-enter").removeAttr("disabled");
                $("#editor-save-enter").off();
                $("#editor-save-cancel").off();
                $("#editor-save-close").off();
                enterClickHandler($("#editor-save-enter"), function () {
                    saveFile(function () {
                        closeEditor();
                    });
                });
                enterClickHandler($("#editor-save-cancel"), function () {
                    editor.getModel().dispose();
                    var model = monaco.editor.createModel("");
                    editor.setModel(model);
                    currentFileVersion = model.getAlternativeVersionId();
                    updateDirtyFlag();
                    closeEditor();
                });
                enterClickHandler($("#editor-save-close"), function () {
                    $("#editor-save-dialog").hide();
                    $("#editor-dialog-back").hide();
                    editor.focus();
                });
                $("#editor-save-dialog").show();
                $("#editor-save-enter").focus();
            }
            e.preventDefault();
        });

        enterClickHandler($("#save-file-editor"), function (e) {
            saveFile(function () { });
            e.preventDefault();
            hideEditorMenu();
        });

        enterClickHandler($("#open-file-editor"), function (e) {
            editor.trigger('openFile', 'editor.action.quickOpenFile');
            e.preventDefault();
            hideEditorMenu();
        });

        enterClickHandler($("#open-command-palette"), function (e) {
            editor.trigger('openCommandPalette', 'editor.action.quickCommand');
            e.preventDefault();
            hideEditorMenu();
        });

        function handleEditorMessage(e) {
            var msg = JSON.parse(e.data);
            if (!msg.fileUri && !msg.folderUri) {
                document.dispatchEvent(new CustomEvent('show', { detail: 'editor' }));
                return;
            }
            document.dispatchEvent(new CustomEvent('show', {
                detail: {
                    component: 'editor',
                    arguments: msg
                }
            }));
        }

        function loadFile(msg, ignoreDirtyFile, createNewFile) {
            createNewFile = createNewFile || false;
            var fileUri = monaco.Uri.parse(msg.fileUri);
            $.ajax(consoleUri + fileUri.toString(), {
                method: 'GET',
                dataType: 'text',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': accessToken,
                    'Accept': 'application/json'
                }
            }).done(function (data, status, jqXHR) {
                if (jqXHR.statusText === "OK") {
                    if (jqXHR.status >= 200 && jqXHR.status <= 299) {
                        showEditor(msg.fileName, fileUri, data, ignoreDirtyFile);
                    } else if (jqXHR.status === 404) {
                        showEditor(msg.fileName, fileUri, '', ignoreDirtyFile);
                    }
                }
            }).fail(function (jqXHR, textStatus, errorThrown) {
                if (createNewFile) {
                    displayFile("Untitled", undefined, "", true);
                } else {
                    $("#editor-dialog-back").show();
                    $("#editor-error-dialog").show();
                    $("#editor-error-head").text($("#editor-error-head").attr("editor-open-error-text"));
                    $("#editor-error-body").html(format($("#editor-error-body").attr("editor-open-error-body"), msg.fileName));
                    $("#editor-error-quit").focus();
                }
            });
        }

        function displayFile(fileName, fileUri, text, isUnsavedFile) {
            isUnsavedFile = isUnsavedFile || false;
            $("#editor-save-dialog").hide();
            $("#editor-dialog-back").hide();
            if (isUnsavedFile) {
                fileUri = monaco.Uri.parse(fileUri);
            }
            editor.getModel().dispose();
            var model = monaco.editor.createModel(text, undefined, fileUri);
            editor.setModel(model);
            document.getElementById('editor-title')
                .textContent = fileName;
            document.getElementById('editor-dirty')
                .style.display = 'none';
            currentFileUri = fileUri;
            currentFileVersion = model.getAlternativeVersionId();
            currentFileName = fileName;
            currentFileUnsaved = isUnsavedFile;
            editor.focus();
        }

        function showEditor(fileName, fileUri, text, ignoreDirtyFile) {
            if (fileIsDirty() && !ignoreDirtyFile) {
                $("#editor-dialog-back").show();
                $("#editor-save-head").text(format($("#editor-save-head").attr("switch-file-text"), currentFileName));
                $("#editor-save-body").text($("#editor-save-body").attr("unsaved-file-warning"));
                $("#editor-save-input-entry").hide();
                $("#editor-save-dialog-buttons").removeClass("with-input");
                $("#editor-save-enter").removeAttr("disabled");
                $("#editor-save-enter").off();
                $("#editor-save-cancel").off();
                $("#editor-save-close").off();
                enterClickHandler($("#editor-save-enter"), function () {
                    saveFile(function () {
                        displayFile(fileName, fileUri, text)
                    });
                });
                enterClickHandler($("#editor-save-cancel"), function () {
                    displayFile(fileName, fileUri, text);
                });
                enterClickHandler($("#editor-save-close"), function () {
                    $("#editor-save-dialog").hide();
                    $("#editor-dialog-back").hide();
                    editor.focus();
                });
                $("#editor-save-dialog").show();
                $("#editor-save-enter").focus();
            }
            else {
                displayFile(fileName, fileUri, text);
            }
        }

        function fileIsDirty() {
            return editor.getModel().getAlternativeVersionId() !== currentFileVersion;
        }

        function updateDirtyFlag() {
            if (fileIsDirty()) {
                $("#editor-dirty").show();
            }
            else {
                $("#editor-dirty").hide();
            }
        }

        function saveFile(callback) {
            if (currentFileUri && currentFileUri.toString() !== "undefined") {
                const savedFileVersion = editor.getModel().getAlternativeVersionId();
                return monaco.Promise.wrap(
                    $.ajax(consoleUri + currentFileUri.toString(), {
                        data: editor.getValue(),
                        method: 'PUT',
                        headers: {
                            'content-type': 'application/json',
                            'Authorization': accessToken
                        }
                    }).done(function (data, status, jqXHR) {
                        if (jqXHR.statusText === "OK") {
                            currentFileVersion = savedFileVersion;
                            currentFileUnsaved = false;
                            document.getElementById('editor-title')
                                .textContent = currentFileName;
                            document.getElementById('editor-dirty')
                                .style.display = 'none';
                            callback();
                        }
                    }).fail(function (jqXHR, textStatus, errorThrown) {
                        $("#editor-dialog-back").show();
                        $("#editor-error-dialog").show();
                        $("#editor-error-head").text($("#editor-error-head").attr("editor-save-error-text"));
                        var destination = currentFolderUri || currentFileUri.replace(currentFileName, "");
                        $("#editor-error-body").html(format($("#editor-error-body").attr("editor-save-error-body"), currentFileName, destination.replace("/files", "")));
                        $("#editor-error-quit").focus();
                    }))
            } else {
                $("#editor-dialog-back").show();
                $("#editor-save-head").text($("#editor-save-head").attr("save-new-file-text"));
                $("#editor-save-body").text($("#editor-save-body").attr("save-new-file-prompt"));
                $("#editor-save-input-entry").show();
                $("#editor-save-dialog-buttons").addClass("with-input");
                $("#editor-save-file-input").val("");
                $("#editor-save-enter").attr("disabled", "");
                $("#editor-save-enter").off();
                $("#editor-save-cancel").off();
                $("#editor-save-close").off();
                $("#editor-save-file-input").on("input", function () {
                    if (!isEmptyOrSpaces($("#editor-save-file-input").val())) {
                        $("#editor-save-enter").removeAttr("disabled");
                    }
                });

                $("#editor-save-file-input").on("keypress", function (e) {
                    if (e.which === 13) {
                        $("#editor-save-enter").click();
                    }
                });

                enterClickHandler($("#editor-save-enter"), function () {
                    currentFileName = $("#editor-save-file-input").val();
                    currentFileUri = (currentFolderUri || "/files" + (codeEditorDirectory || userRootDirectory)) + "/" + currentFileName;
                    currentFileUri = monaco.Uri.parse(currentFileUri);
                    $("#editor-save-dialog").hide();
                    $("#editor-dialog-back").hide();
                    editor.focus();
                    saveFile(callback);
                });
                enterClickHandler($("#editor-save-cancel"), function () {
                    $("#editor-save-dialog").hide();
                    $("#editor-dialog-back").hide();
                    editor.focus();
                    callback();
                });
                enterClickHandler($("#editor-save-close"), function () {
                    $("#editor-save-dialog").hide();
                    $("#editor-dialog-back").hide();
                    editor.focus();
                });
                $("#editor-save-dialog").show();
                $("#editor-save-file-input").focus();
                //return null;
            }
        }

        editor.onDidChangeModelContent(updateDirtyFlag);

        editor.addAction({
            id: 'save',
            label: 'Save',
            keybindings: [
                monaco.KeyMod.CtrlCmd | monaco.KeyCode.KEY_S
            ],
            contextMenuGroupId: '98_save',
            run: function (ed) {
                saveFile(function () { });
            }
        });

        editor.addAction({
            id: 'quit',
            label: 'Quit',
            keybindings: [
                monaco.KeyMod.CtrlCmd | monaco.KeyCode.KEY_Q
            ],
            contextMenuGroupId: '99_quit',
            run: function (ed) {
                $("#hide-editor").click();
            }
        });

        editor.addAction({
            id: 'terminal',
            label: 'Terminal',
            keybindings: [
                monaco.KeyMod.CtrlCmd | monaco.KeyCode.US_BACKTICK
            ],
            run: function (ed) {
                term.focus();
            }
        });
    });
});
