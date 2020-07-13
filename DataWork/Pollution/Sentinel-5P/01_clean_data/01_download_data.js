// =============================================================
  // Extract Daily Sentinel 5P 
// =============================================================
  
  // DESCRIPTION: Given (1) start and end dates, (2) country name 
// and (3) pollution type (eg, no2), creates a stacked raster
// layer where each raster stack is a day.

// https://developers.google.com/earth-engine/datasets/catalog/sentinel-5p

// DEFINE FUNCTIONS ============================================
  
  // Function to turn imagecollection into image with bands
var stackCollection = function(collection) {
  // Create an initial image.
  var first = ee.Image(collection.first()).select([]);
  
  // Write a function that appends a band to an image.
  var appendBands = function(image, previous) {
    return ee.Image(previous).addBands(image);
  };
  return ee.Image(collection.iterate(appendBands, first));
};

// Function that extracts data for a given day
// Adapted from here:
  // https://gis.stackexchange.com/questions/269313/mapping-over-list-of-dates-in-google-earth-engine
var extract_pltn_daily = function(d1, country_name, s5p_type) {
  
  // 1. Start and end dates
  var start = ee.Date(d1);
  var end = ee.Date(d1).advance(1,'day');
  
  // 2. Load data and subset
  var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');
  var country = countries.filter(ee.Filter.eq('country_na', country_name));
  
  // Load Image
  if(s5p_type == "uv"){
    var image = ee.ImageCollection("COPERNICUS/S5P/OFFL/L3_AER_AI"); 
    image = image.select('absorbing_aerosol_index');
  }
  
  if(s5p_type == "co"){
    var image = ee.ImageCollection("COPERNICUS/S5P/OFFL/L3_CO"); 
    image = image.select('CO_column_number_density');
  }
  
  if(s5p_type == "hcho"){
    var image = ee.ImageCollection("COPERNICUS/S5P/OFFL/L3_HCHO"); 
    image = image.select('tropospheric_HCHO_column_number_density');
  }
  
  if(s5p_type == "no2"){
    var image = ee.ImageCollection("COPERNICUS/S5P/OFFL/L3_NO2"); 
    image = image.select('NO2_column_number_density');
  }
  
  if(s5p_type == "o3"){
    var image = ee.ImageCollection("COPERNICUS/S5P/OFFL/L3_O3"); 
    image = image.select('O3_column_number_density');
  }
  
  if(s5p_type == "so2"){
    var image = ee.ImageCollection("COPERNICUS/S5P/OFFL/L3_SO2"); 
    image = image.select('SO2_column_number_density');
  }
  
  if(s5p_type == "ch4"){
    var image = ee.ImageCollection("COPERNICUS/S5P/OFFL/L3_CH4"); 
    image = image.select('CH4_column_volume_mixing_ratio_dry_air');
  }
  
  // Date Subset
  image = ee.ImageCollection(
    image.filterDate(start, end)
  );
  
  // Mean
  image = image.mean()
  
  // Make sure data types are all the same 
  image = image.float()
  
  // Country
  image = image.clip(country);
  
  return(image);
};

// Function to extract pollution and send data to google drive
var extract_pollution = function(country_name, begin_date, end_date, s5p_type, gdrive_folder, image_name){
  // PARAMETERS
  // country_name: Name of a country
  // begin_date: Start date (in format: yyyy-mm-dd)
  // end_date: End date (in format: yyyy-mm-dd)
  // pollution_type: Type of pollution, either: uv, co, hcho, no2, o3, so2, ch4
  // gdrive_folder: Name of folder in google drive to extract data
  // image_name: Name of raster to output
  
  
  // ** Load country
  var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');
  var country = countries.filter(ee.Filter.eq('country_na', country_name));
  
  // ** List of Dates
  // https://gis.stackexchange.com/questions/280156/mosaicking-a-image-collection-by-date-day-in-google-earth-engine
  
  // Need to add one day to end date, as below list doesn't include original end date
  var Date_Start = ee.Date(begin_date);
  var Date_End = ee.Date(end_date).advance(1,'day'); 
  
  var diff = Date_End.difference(Date_Start, 'day')
  
  // Make a list of all dates
  var dates = ee.List.sequence(0, diff.subtract(1)).map(function(day){return Date_Start.advance(day,'day')})

  // ** Extract data for each date and append as image stack
  // var image_list = dates.map(extract_pltn_daily);
  // Map over function with multiple arguments:
    // https://stackoverflow.com/questions/12344087/using-javascript-map-with-a-function-that-has-two-arguments

  var image_list = dates.map(
    function(x) { return extract_pltn_daily(x, country_name, s5p_type); }
  );

  var image_collection = ee.ImageCollection(image_list);
  var image_stack = stackCollection(image_collection);
  

  // ** Export to Google Drive
  Export.image.toDrive({
    folder: gdrive_folder,
    image: image_stack,
    scale: 1000,
    region: country.geometry().bounds(),
    description: image_name,
  });
  
};

// Function to extract daily data in monthly chunks
var extract_pollution_daily_bymonth = function(country_name, s5p_type, gdrive_folder){
  
  var image_name_root = country_name + "_" + s5p_type + "_"
  
  extract_pollution(country_name, '2019-01-01', '2019-01-31', s5p_type, gdrive_folder, image_name_root + '201901');
  extract_pollution(country_name, '2019-02-01', '2019-02-28', s5p_type, gdrive_folder, image_name_root + '201902');
  extract_pollution(country_name, '2019-03-01', '2019-03-31', s5p_type, gdrive_folder, image_name_root + '201903');
  extract_pollution(country_name, '2019-04-01', '2019-04-30', s5p_type, gdrive_folder, image_name_root + '201904');
  extract_pollution(country_name, '2019-05-01', '2019-05-31', s5p_type, gdrive_folder, image_name_root + '201905');
  extract_pollution(country_name, '2019-06-01', '2019-06-30', s5p_type, gdrive_folder, image_name_root + '201906');
  extract_pollution(country_name, '2019-07-01', '2019-07-31', s5p_type, gdrive_folder, image_name_root + '201907');
  extract_pollution(country_name, '2019-08-01', '2019-08-31', s5p_type, gdrive_folder, image_name_root + '201908');
  extract_pollution(country_name, '2019-09-01', '2019-09-30', s5p_type, gdrive_folder, image_name_root + '201909');
  extract_pollution(country_name, '2019-10-01', '2019-10-31', s5p_type, gdrive_folder, image_name_root + '201910');
  extract_pollution(country_name, '2019-11-01', '2019-11-30', s5p_type, gdrive_folder, image_name_root + '201911');
  extract_pollution(country_name, '2019-12-01', '2019-12-31', s5p_type, gdrive_folder, image_name_root + '201912');
};

// EXTRACT DATA ==============================================
// If want latest date, give really large end date and just 
// extracts latest
// uv, co, hcho, no2, o3, so2, ch4
extract_pollution('Iraq', '2019-01-01', '2030-12-31', 'uv',   'gee_extracts', 'iraq_uv_daily_start20190101');
extract_pollution('Iraq', '2019-01-01', '2030-12-31', 'co',   'gee_extracts', 'iraq_co_daily_start20190101');
extract_pollution('Iraq', '2019-01-01', '2030-12-31', 'hcho', 'gee_extracts', 'iraq_hcho_daily_start20190101');
extract_pollution('Iraq', '2019-01-01', '2030-12-31', 'no2',  'gee_extracts', 'iraq_no2_daily_start20190101');
extract_pollution('Iraq', '2019-01-01', '2030-12-31', 'o3',   'gee_extracts', 'iraq_o3_daily_start20190101');
extract_pollution('Iraq', '2019-01-01', '2030-12-31', 'so2',  'gee_extracts', 'iraq_so2_daily_start20190101');
extract_pollution('Iraq', '2019-01-01', '2030-12-31', 'ch4',  'gee_extracts', 'iraq_ch4_daily_start20190101');


