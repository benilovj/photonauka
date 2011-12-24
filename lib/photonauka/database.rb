class Devices
  def initialize
    @device_groups = []
  end

  def with *device_groups
    @device_groups = device_groups
    self
  end

  def group_names
    @device_groups.map {|group| group.name}
  end

  def devices_in_group(group_name)
    @device_groups.find {|group| group.name == group_name}.devices
  end
end

class DeviceGroup
  attr_reader :devices
  attr_reader :name

  def initialize(name)
    @name = name
    @devices = []
  end

  def with *device_pairs
    @devices = device_pairs.map {|id, description| DeviceRepresentation.new(id, description)}
    self
  end
end

class DeviceRepresentation < Struct.new(:device_id, :description)
  def filename
    'zoom_2x2_128pc/zoom_2x2_128_%03d' % device_id
  end
end

DEVICE_REPRESENTATIONS = Devices.new.with(
  DeviceGroup.new("Studio Equipment").with(
    [1, "Background, 275, On Wall"],
    [102, "Background, 275, On Floor"],
    [2, "Background, 365, On Wall"],
    [103, "Background, 365, On Floor"],
    [3, "Background, 610, On Wall"],
    [104, "Background, 610, On Floor"],
    [4, "Still Life Table, 75x75"],
    [5, "Still Life Table, 125x125"],
    [6, "Firm Camera Stand"]),
  DeviceGroup.new("Cameras").with(
    [7, "35 mm DSLR, On Stand"],
    [99 ,"35 mm DSLR, Alone"],
    [8, "Medium Format DSLR, On Stand"],
    [100, "Medium Format DSLR, Alone"],
    [9, "Large Format, On Stand"],
    [101, "Large Format, Alone"]),
  DeviceGroup.new("Lenses").with(
    [10, "14"],
    [10, "15"],
    [10, "20"],
    [10, "24"],
    [10, "28"],
    [10, "35"],
    [10, "50"],
    [10, "60"],
    [10, "80"],
    [10, "85"],
    [10, "100"],
    [10, "135"],
    [10, "150"],
    [10, "200"],
    [10, "300"],
    [10, "Custom"]),
  DeviceGroup.new("Models").with(
    [26, "Model (boy)"], 
    [105, "Model (girl)"], 
    [27, "Subject"], 
    [28, "Car"], 
    [29, "Couch"], 
    [30, "Chair"], 
    [31, "Custom Size"]),
  DeviceGroup.new("Strobe Lighting").with(
    [32, "Strobe"],
    [33, "Strobe / Grid"],
    [34, "Strobe / Gel"],
    [35, "Strobe / Snoot"],
    [36, "Strobe / Barndoors"],
    [98, "Strobe / Boom / Softbox"],
    [37, "Strobe / Boom"],
    [38, "Strobe / Boom / Grid"],
    [39, "Strobe / Boom / Ring Flash"],
    [40, "Strobe / Boom / Beauty Dish"],
    [41, "Beauty Dish"],
    [42, "Beauty Dish / Diffuser"],
    [43, "On Camera Flash"],
    [133, "Zoom Spot"],
    [44, "Ring Flash"]),
  DeviceGroup.new("Softboxes").with(
    [45, "Square 70x70 with GRID"],
    [106, "Square 70x70 w/o GRID"],
    [46, "Square 100x100 with GRID"],
    [107, "Square 100x100 w/o GRID"],
    [47, "Square 145x145 with GRID"],
    [108, "Square 145x145 w/o GRID"],
    [48, "Rectangular 60x80 with GRID"],
    [120, "Rectangular 60x80 with GRID (V)"],
    [109, "Rectangular 60x80 w/o GRID"],
    [121, "Rectangular 60x80 w/o GRID (V)"],
    [49, "Rectangular 70x170 with GRID"],
    [122, "Rectangular 70x170 with GRID (V)"],
    [110, "Rectangular 70x170 w/o GRID"],
    [123, "Rectangular 70x170 w/o GRID (V)"],
    [50, "Rectangular 90x110 with GRID"],
    [124, "Rectangular 90x110 with GRID (V)"],
    [111, "Rectangular 90x110 w/o GRID"],
    [125, "Rectangular 90x110 w/o GRID (V)"],
    [51, "Strip 35x60 with GRID"],
    [126, "Strip 35x60 with GRID (V)"],
    [112, "Strip 35x60 w/o GRID"],
    [127, "Strip 35x60 w/o GRID (V)"],
    [52, "Strip 35x90 with GRID"],
    [128, "Strip 35x90 with GRID (V)"],
    [113, "Strip 35x90 w/o GRID"],
    [129, "Strip 35x90 w/o GRID (V)"],
    [53, "Strip 35x175 with GRID"],
    [130, "Strip 35x175 with GRID (V)"],
    [114, "Strip 35x175 w/o GRID"],
    [131, "Strip 35x175 w/o GRID (V)"],
    [54, "Octabox 100 Diameter with GRID"],
    [115, "Octabox 100 Diameter w/o GRID"],
    [55, "Octabox 150 Diameter with GRID"],
    [116, "Octabox 150 Diameter w/o GRID"],
    [56, "Octabox 190 Diameter with GRID"],
    [117, "Octabox 190 Diameter w/o GRID"],
    [57, "Deep Octobox 70 Diameter with GRID"],
    [118, "Deep Octobox 70 Diameter w/o GRID"],
    [58, "Deep Octobox 100 Diameter with GRID"],
    [119, "Deep Octobox 100 Diameter w/o GRID"]),
  DeviceGroup.new("Umbrellas").with(
    [59, "Umbrella Softbox, 75 Diameter"],
    [60, "Umbrella Softbox, 100 Diameter"],
    [61, "Bounce Umbrella, 75 Diameter"],
    [62, "Bounce Umbrella, 100 Diameter"],
    [63, "Through Umbrella, 75 Diameter"],
    [64, "Through Umbrella, 100 Diameter"]),
  DeviceGroup.new("Continuous Lighting").with(
    [66, "Tungsten Flood Light Reflector 30 Diameter"],
    [67, "Tungsten Fresnel Light 150 WATT"],
    [68, "Tungsten Fresnel Light 300 WATT"],
    [69, "Tungsten Fresnel Light 650 WATT"],
    [70, "Tungsten Fill Light 1000 WATT"],
    [71, "Tungsten Fill Light 2000 WATT"],
    [72, "Fluorescent Fixture 140x45"],
    [73, "Fluorescent Fixture 60x60"],
    [74, "Fluorescent Fixture 90x90"],
    [75, "LED Lighting Light Panel"],
    [76, "LED Lighting Ring Light"],
    [77, "HMI Fresnel Light 1800 WATT"],
    [78, "HMI Fresnel Light 4000 WATT"],
    [79, "HMI Fresnel Light 6000 WATT"],
    [80, "HMI Flood Light 250 WATT "],
    [81, "Ambient Light Window 500"],
    [82, "Ambient Light Window 200"],
    [83, "Ambient Light Window 100"]),
  DeviceGroup.new("Reflectors").with(
    [84, "Round Small"],
    [85, "Round Bigger"],
    [86, "Rectangular 120x80"],
    [87, "Rectangular Polyboard White"],
    [132, "Rectangular Polyboard Black"],
    [88, "Square 500x500"],
    [89, "Square 1000x1000"]),
  DeviceGroup.new("Diffusers").with(
    [90, "Diffuser 100x100"],
    [91, "Diffuser 200x200"],
    [92, "Diffuser 500x500"],
    [93, "Diffuser 1000x1000"]),
  DeviceGroup.new("Cutters").with(
    [94, "Cutter 30x120"],
    [95, "Cutter 90x110"],
    [96, "Cutter 120x120"],
    [97, "Cutter 145x145"])
)
