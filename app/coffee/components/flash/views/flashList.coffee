
class FlashChild extends Marionette.LayoutView
  className: 'row'
  template: require './templates/flash_child'

  attributes:
    style: 'display:none;'

  ui:
    close: '[data-click=dismiss]'

  events:
    'click @ui.close': 'dismiss'

  onShow: ->
    timeout = @model.get('timeout')
    setTimeout( @dismiss, timeout )

  onAttach: ->
    @$el.fadeIn()

  remove: ->
    @$el.slideToggle( =>
      Marionette.LayoutView.prototype.remove.call(@)
    )

  dismiss: =>
    @model.collection?.remove( @model ) # QUESTION - is this memory safe?

# # # # #

class FlashList extends Marionette.CollectionView
  className: 'container-fluid'
  childView: FlashChild

# # # # #

module.exports = FlashList
