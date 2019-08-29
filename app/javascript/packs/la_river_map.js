import baseMap from "./base_map.js";

var asvsLayer;
var inatLayer;
var samplesData;
var baseSamplesData;
var inatData;
var showAsvs = true;

var map = baseMap.createMap();

var inatApiEndpoint = `/api/v1/inat_observations`;
$.get(inatApiEndpoint, function(data) {
  inatData = data.data.map(function(observation) {
    return baseMap.formatInatData(observation);
  });

  inatLayer = createMarkerLayer(inatData, inatLayer, map);
});

var apiEndpoint = "/api/v1/samples";
$.get(apiEndpoint, function(data) {
  console.log(data);
  samplesData = data.samples.data.map(function(sample) {
    return baseMap.formatSamplesData(sample);
  });

  asvsLayer = createMarkerLayer(samplesData, asvsLayer, map);
});

function createMarkerLayer(data, layer, map) {
  var markers = data.map(record => {
    return baseMap.createCircleMarker(record);
  });

  layer = L.layerGroup(markers);
  layer.addTo(map);
  return layer;
}

baseMap.createOverlayEventListeners(map);
baseMap.createOverlays(map);
baseMap.addMapLayerModal(map);

var taxaMarkerEls = document.querySelectorAll(".js-taxa-markers");
if (taxaMarkerEls) {
  taxaMarkerEls.forEach(function(el) {
    el.addEventListener("click", function(event) {
      var format = event.target.value;
      var checked = event.target.checked;

      if (format == "presence") {
        if (checked) {
          presenceLayer = baseMap.renderBasicIndividualMarkers(
            baseSamplesData,
            map
          );

          // rerender asvsLayer to ensure asvs markers are on top of presence markers
          if (showAsvs) {
            map.removeLayer(asvsLayer);
            asvsLayer = baseMap.renderIndividualMarkers(samplesData, map);
          }
        } else if (presenceLayer) {
          map.removeLayer(presenceLayer);
        }
      } else if (format == "asvs") {
        if (checked) {
          asvsLayer = baseMap.renderIndividualMarkers(samplesData, map);
          showAsvs = true;
        } else if (asvsLayer) {
          map.removeLayer(asvsLayer);
          showAsvs = false;
        }
      } else if (format == "inat") {
        if (checked) {
          inatLayer = createMarkerLayer(inatData, inatLayer, map);
        } else if (inatLayer) {
          map.removeLayer(inatLayer);
        }
      }
    });
  });
}