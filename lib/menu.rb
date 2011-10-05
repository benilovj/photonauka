module HotCocoa
  def application_menu
    menu do |main|
      main.submenu :apple do |apple|
        apple.item :about, title: "About #{NSApp.name}"
        apple.separator
        apple.item :preferences, key: ','
        apple.separator
        apple.submenu :services
        apple.separator
        apple.item :hide, title: "Hide #{NSApp.name}", key: 'h'
        apple.item :hide_others, title: 'Hide Others', key: 'h', modifiers: [:command, :alt]
        apple.item :show_all, title: 'Show All'
        apple.separator
        apple.item :quit, title: "Quit #{NSApp.name}", key: 'q'
      end
      main.submenu :file do |file|
        file.item :save_as, title: "Save As...", key: 's', modifiers: [:command, :shift]
        file.separator
        file.item :print, key: 'p'
      end
    end
  end
end
