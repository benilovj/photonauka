module I18n
  def self.t key
    NSBundle.mainBundle.localizedStringForKey(key, value: nil, table: nil)
  end
end

module HotCocoa
  def application_menu
    menu do |main|
      main.submenu :apple do |apple|
        apple.item :about, title: I18n.t("apple:about")
        apple.separator
        apple.item :preferences, title: I18n.t("apple:preferences"), key: ','
        apple.separator
        apple.submenu :services, title: I18n.t("apple:services")
        apple.separator
        apple.item :hide, title: I18n.t("apple:hide"), key: 'h'
        apple.item :hide_others, title: I18n.t("apple:hide_others"), key: 'h', modifiers: [:command, :alt]
        apple.item :show_all, title: I18n.t("apple:show_all")
        apple.separator
        apple.item :quit, title: I18n.t("apple:quit"), key: 'q'
      end
      main.submenu :file, title: I18n.t("file") do |file|
        file.item :new, title: I18n.t("file:new"), key: 'n', action: 'newDocument:'
        file.item :open, title: I18n.t("file:open"), key: 'o', action: 'openDocument:'
        file.separator
        file.item :close, title: I18n.t("file:close"), key: 'w', action: 'performClose:'
        file.item :save, title: I18n.t("file:save"), key: 's', action: 'saveDocument:'
        file.item :save_as, title: I18n.t("file:save_as"), key: 's', modifiers: [:command, :shift], action: 'saveDocumentAs:'
        file.separator
        file.item :print, title: I18n.t("file:print"), key: 'p', action: 'printDocument:'
      end
      main.submenu :edit, title: I18n.t("edit") do |file|
        file.item :undo, title: I18n.t("edit:undo"), key: 'z', action: 'undo:'
        file.item :redo, title: I18n.t("edit:redo"), key: 'z', modifiers: [:command, :shift], action: 'redo:'
      end
    end
  end
end
