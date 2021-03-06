function isFunction(functionToCheck) {
    var getType = {};
    return functionToCheck && getType.toString.call(functionToCheck) === '[object Function]';
}

L.TileLayer.custom_d3_geoJSON = L.TileLayer.extend({
    onAdd: function(map) {
        L.TileLayer.prototype.onAdd.call(this, map);
        this._path = d3.geo.path().projection(function(d) {
            var point = map.latLngToLayerPoint(new L.LatLng(d[1], d[0]));
            return [point.x, point.y];
        });
        this.on("tileunload", function(d) {
            if (d.tile.xhr) d.tile.xhr.abort();
            if (d.tile.nodes) d.tile.nodes.remove();
            d.tile.nodes = null;
            d.tile.xhr = null;
        });
    },
    onRemove: function(map) {
        var layerClass = this.options.class;
        if (isFunction(layerClass)) {
            layerClass = layerClass();
        }
        L.TileLayer.prototype.onRemove.call(this, map);
        d3.select(map._container).select("svg").selectAll("." + layerClass).remove();
    },
    _loadTile: function(tile, tilePoint) {
        var self = this;
        this._adjustTilePoint(tilePoint);

        if (!tile.nodes && ! tile.xhr) {
            tile.xhr = d3.json(this.getTileUrl(tilePoint), function(geoJson) {
                tile.xhr = null;
                tile.nodes = d3.select(map._container).select("svg").append("g");

                if (self.options.type === "path") {
                    tile.nodes.selectAll("path").data(geoJson.features)
                        .enter()
                        .append(self.options.type)
                        .attr("d", self._path)
                        .attr("class", self.options.class)
                        .attr("style", self.options.style)
                        .attr("title", self.options.title)
                        .attr("data-content", self.options.content)
                        .on('mouseover', self.options.mouseover)
                        .on('mouseout', self.options.mouseout)
                        .on('click', self.options.click)
                        ;
                        $("path").popover({
                            "html":true,
                            "animation":false,
                            "container":"body",
                            "trigger":"hover"
                        });
                }
                if (self.options.type === "circle") {
                    tile.nodes.selectAll("path").data(geoJson.features)
                        .enter()
                        .append(self.options.type)
                        .attr("d", self._path)
                        .attr("cx", function(d) {
                            var pixels = map.latLngToLayerPoint(new L.LatLng(d.geometry.coordinates[1], d.geometry.coordinates[0]));
                            return pixels.x;
                        })
                        .attr("cy", function(d) {
                            var pixels = map.latLngToLayerPoint(new L.LatLng(d.geometry.coordinates[1], d.geometry.coordinates[0]));
                            return pixels.y;
                        })
                        .attr("class", self.options.class)
                        .attr("r", self.options.radius)
                        .attr("fill", function(d) {
                            if (self.options.class === "warehouse") {
                                var colorFill;
                                switch ("" + d.properties.owner) {
                                case "Costco":
                                    colorFill = "blueviolet";
                                    break;
                                case "Target":
                                    colorFill = "fuchsia";
                                    break;
                                case "Walmart":
                                    colorFill = "darkorange";
                                    break;
                                case "Krogers":
                                    colorFill = "mediumslateblue";
                                    break;
                                case "Walgreens":
                                    colorFill = "limegreen";
                                    break;
                                case "Amazon":
                                    colorFill = "forestgreen";
                                    break;
                                case "Home Depot":
                                    colorFill = "maroon";
                                    break;
                                case "Ikea":
                                    colorFill = "navy";
                                    break;
                                default:
                                    colorFill = "darkorange";
                                    break;
                                }
                                return colorFill;
                            } else {
                                return self.options.fill;
                            }
                        })
                        .attr("title", self.options.title)
                        .attr("data-content", self.options.content)
                        .on('mouseover', self.options.mouseover)
                        .on('mouseout', self.options.mouseout)
                        .on('click', self.options.click)
                        ;
                        $("circle").popover({
                            "html":true,
                            "animation":false,
                            "container":"body",
                            "trigger":"hover"
                        });
                }
            });
        }
    }
});

