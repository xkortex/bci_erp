# NodeWebKit package.json
config =
  name:     'NodeWebKit Boilerplate'
  version:  '0.0.1'
  main:     'index.html'
  window:
    title:      'NodeWebKit Demo'
    icon:       './img/icon.png'
    toolbar:    true
    frame:      true
    position:   'mouse'
    width:      1200
    height:     900
    min_width:  400
    min_height: 200
    max_width:  800
    max_height: 600

# # # # #

module.exports = JSON.stringify(config, null, 2)


