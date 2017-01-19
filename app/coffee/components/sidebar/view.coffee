
# SidebarView class definition
# The SidebarView renders the app's sidebar with
# the menuItems specified below
class SidebarView extends Marionette.LayoutView
  template: require './template'
  className: 'nav nav-pills nav-stacked'
  tagName: 'nav'

  events:
    'click a': 'onClicked'

  onClicked: ->
    Backbone.Radio.channel('sidebar').trigger('hide')

  modules: [
    { title:  'Home', icon: 'fa-home', href: '#', divider: true }
    { title:  'Upload', icon: 'fa-upload', href: '#upload', divider: true }
    { title:  'Python', icon: 'fa-terminal', href: '#python', divider: true }
  ]

  serializeData: ->
    return { modules: @modules }

# # # # #

module.exports = SidebarView
