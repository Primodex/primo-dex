#!/bin/bash
# build_data.sh — Download NOAA 1991-2020 Hourly Normals and extract monthly averages
# Outputs city_data.json with monthly temp, dew point, and heat index for ~50 U.S. metros

WORK_DIR="C:/Users/campi/Fractl Campaigns"
RAW_DIR="$WORK_DIR/noaa_raw"
TSV_FILE="$WORK_DIR/monthly_raw.tsv"
OUTPUT="$WORK_DIR/city_data.json"
BASE_URL="https://www.ncei.noaa.gov/data/normals-hourly/1991-2020/access"

mkdir -p "$RAW_DIR"

# Station definitions: "city|state|station_id|lat|lon|region"
STATIONS=(
  "New York|NY|USW00094789|40.64|-73.76|Northeast"
  "Los Angeles|CA|USW00023174|33.94|-118.41|West"
  "Chicago|IL|USW00094846|41.96|-87.93|Midwest"
  "Dallas-Fort Worth|TX|USW00003927|32.90|-97.02|South"
  "Houston|TX|USW00012960|29.97|-95.36|South"
  "Washington DC|DC|USW00013743|38.85|-77.03|South"
  "Philadelphia|PA|USW00013739|39.87|-75.23|Northeast"
  "Miami|FL|USW00012839|25.79|-80.29|South"
  "Atlanta|GA|USW00013874|33.63|-84.44|South"
  "Boston|MA|USW00014739|42.36|-71.01|Northeast"
  "Phoenix|AZ|USW00023183|33.43|-112.02|West"
  "San Francisco|CA|USW00023234|37.62|-122.37|West"
  "Detroit|MI|USW00094847|42.23|-83.33|Midwest"
  "Seattle|WA|USW00024233|47.44|-122.31|West"
  "Minneapolis|MN|USW00014922|44.88|-93.23|Midwest"
  "San Diego|CA|USW00023188|32.73|-117.17|West"
  "Tampa|FL|USW00012842|27.96|-82.54|South"
  "Denver|CO|USW00003017|39.83|-104.66|West"
  "St. Louis|MO|USW00013994|38.75|-90.37|Midwest"
  "Baltimore|MD|USW00093721|39.17|-76.68|South"
  "Orlando|FL|USW00012815|28.43|-81.33|South"
  "Charlotte|NC|USW00013881|35.21|-80.94|South"
  "San Antonio|TX|USW00012921|29.53|-98.47|South"
  "Portland|OR|USW00024229|45.59|-122.60|West"
  "Sacramento|CA|USW00023232|38.51|-121.50|West"
  "Pittsburgh|PA|USW00094823|40.49|-80.23|Northeast"
  "Las Vegas|NV|USW00023169|36.08|-115.15|West"
  "Cincinnati|OH|USW00093812|39.10|-84.42|Midwest"
  "Kansas City|MO|USW00003947|39.30|-94.71|Midwest"
  "Columbus|OH|USW00014821|40.00|-82.88|Midwest"
  "Indianapolis|IN|USW00093819|39.73|-86.28|Midwest"
  "Cleveland|OH|USW00014820|41.41|-81.85|Midwest"
  "Nashville|TN|USW00013897|36.12|-86.69|South"
  "Virginia Beach|VA|USW00013737|36.90|-76.19|South"
  "Providence|RI|USW00014765|41.72|-71.43|Northeast"
  "Milwaukee|WI|USW00014839|42.95|-87.90|Midwest"
  "Jacksonville|FL|USW00013889|30.49|-81.69|South"
  "Oklahoma City|OK|USW00013967|35.39|-97.60|South"
  "Raleigh|NC|USW00013722|35.87|-78.79|South"
  "Memphis|TN|USW00013893|35.06|-89.99|South"
  "Richmond|VA|USW00013740|37.51|-77.32|South"
  "New Orleans|LA|USW00012916|30.00|-90.25|South"
  "Louisville|KY|USW00093821|38.17|-85.73|South"
  "Salt Lake City|UT|USW00024127|40.77|-111.97|West"
  "Hartford|CT|USW00014740|41.94|-72.68|Northeast"
  "Birmingham|AL|USW00013876|33.57|-86.75|South"
  "Buffalo|NY|USW00014733|42.94|-78.74|Northeast"
  "Rochester|NY|USW00014768|43.12|-77.68|Northeast"
  "Tucson|AZ|USW00023160|32.13|-110.96|West"
  "El Paso|TX|USW00023044|31.81|-106.38|West"
  "West Palm Beach|FL|USW00012836|26.68|-80.10|South"
  "Fort Myers|FL|USW00012844|26.59|-81.86|South"
  "Honolulu|HI|USW00022521|21.32|-157.93|West"
  "Riverside|CA|USW00023119|33.90|-117.25|West"
  "Grand Rapids|MI|USW00094860|42.89|-85.54|Midwest"
  "Tulsa|OK|USW00013968|36.20|-95.89|South"
  "Fresno|CA|USW00093193|36.78|-119.72|West"
  "Omaha|NE|USW00014942|41.31|-95.90|Midwest"
  "Greenville|SC|USW00003870|34.88|-82.22|South"
  "Albuquerque|NM|USW00023050|35.04|-106.62|West"
  "Bakersfield|CA|USW00023155|35.43|-119.05|West"
  "Albany|NY|USW00014735|42.74|-73.81|Northeast"
  "Knoxville|TN|USW00013891|35.82|-83.99|South"
  "Allentown|PA|USW00014737|40.65|-75.45|Northeast"
  "Oxnard|CA|USW00023136|34.22|-119.08|West"
  "Columbia|SC|USW00013883|33.95|-81.12|South"
  "Dayton|OH|USW00093815|39.91|-84.22|Midwest"
  "Charleston|SC|USW00013880|32.90|-80.04|South"
  "Greensboro|NC|USW00013723|36.10|-79.94|South"
  "Boise|ID|USW00024131|43.57|-116.24|West"
  "Colorado Springs|CO|USW00093037|38.81|-104.69|West"
  "Little Rock|AR|USW00013963|34.73|-92.24|South"
  "Des Moines|IA|USW00014933|41.53|-93.65|Midwest"
  "Madison|WI|USW00014837|43.14|-89.35|Midwest"
  "Syracuse|NY|USW00014771|43.11|-76.10|Northeast"
  "Wichita|KS|USW00003928|37.65|-97.44|Midwest"
  "Augusta|GA|USW00003820|33.37|-81.96|South"
  "Jackson|MS|USW00003940|32.32|-90.08|South"
  "Melbourne|FL|USW00012838|28.10|-80.64|South"
  "Spokane|WA|USW00024157|47.62|-117.53|West"
)

# ============================================================
# Step 1: Download all CSVs
# ============================================================
echo "=== Downloading NOAA Hourly Normals ==="
success_count=0
fail_count=0

for entry in "${STATIONS[@]}"; do
  IFS='|' read -r city state sid lat lon region <<< "$entry"
  outfile="$RAW_DIR/$sid.csv"
  if [ -f "$outfile" ] && [ -s "$outfile" ]; then
    echo "  Cached: $city ($sid)"
    ((success_count++))
  else
    if curl -sf -o "$outfile" "$BASE_URL/$sid.csv" 2>/dev/null; then
      echo "  Downloaded: $city ($sid)"
      ((success_count++))
    else
      echo "  FAILED: $city ($sid)"
      rm -f "$outfile"
      ((fail_count++))
    fi
    sleep 0.3
  fi
done

echo ""
echo "Downloads complete: $success_count succeeded, $fail_count failed"
echo ""

# ============================================================
# Step 2: Process each CSV into monthly averages
# ============================================================
echo "=== Processing CSVs ==="
> "$TSV_FILE"

for entry in "${STATIONS[@]}"; do
  IFS='|' read -r city state sid lat lon region <<< "$entry"
  csvfile="$RAW_DIR/$sid.csv"
  [ ! -f "$csvfile" ] || [ ! -s "$csvfile" ] && continue

  awk -v city="$city" -v state="$state" -v lat="$lat" -v lon="$lon" -v region="$region" \
  'BEGIN {
    FPAT = "([^,]*)|(\"[^\"]*\")"
    for(m=1;m<=12;m++){
      ts[m]=0;tc[m]=0;ds[m]=0;dc[m]=0;hs[m]=0;hc[m]=0
      tds[m]=0;tdc[m]=0;tns[m]=0;tnc[m]=0
      ws[m]=0;wc[m]=0
      cclrs[m]=0;cclrc[m]=0;cfews[m]=0;cfewc[m]=0
      cscts[m]=0;csctc[m]=0;cbkns[m]=0;cbknc[m]=0
      covcs[m]=0;covcc[m]=0
      hihr[m]=0
    }
    elev=0
  }
  function s(v){gsub(/[" \t]/,"",v);return v+0}
  NR==2{ elev=s($5) }
  NR>1{
    m=s($7); t=s($10); d=s($22); hi=s($74)
    hr=s($9); w=s($82)
    cl=s($54); cf=s($58); cs=s($62); cb=s($66); co=s($70)
    if(m>=1 && m<=12){
      if(t>-9000){ts[m]+=t;tc[m]++
        if(hr>=6 && hr<=19){tds[m]+=t;tdc[m]++}
        else{tns[m]+=t;tnc[m]++}
      }
      if(d>-9000){ds[m]+=d;dc[m]++}
      if(hi>-9000){hs[m]+=hi;hc[m]++}
      if(w>-9000){ws[m]+=w;wc[m]++}
      if(cl>-9000){cclrs[m]+=cl;cclrc[m]++}
      if(cf>-9000){cfews[m]+=cf;cfewc[m]++}
      if(cs>-9000){cscts[m]+=cs;csctc[m]++}
      if(cb>-9000){cbkns[m]+=cb;cbknc[m]++}
      if(co>-9000){covcs[m]+=co;covcc[m]++}
      if(hi>=80) hihr[m]++
    }
  }
  END{
    t_str="";d_str="";h_str=""
    td_str="";tn_str="";w_str=""
    cclr_str="";cfew_str="";csct_str="";cbkn_str="";covc_str=""
    hihr_str=""
    for(m=1;m<=12;m++){
      sep=(m>1?",":"")
      t_str=t_str sep sprintf("%.1f",tc[m]>0?ts[m]/tc[m]:0)
      d_str=d_str sep sprintf("%.1f",dc[m]>0?ds[m]/dc[m]:0)
      h_str=h_str sep sprintf("%.1f",hc[m]>0?hs[m]/hc[m]:0)
      td_str=td_str sep sprintf("%.1f",tdc[m]>0?tds[m]/tdc[m]:0)
      tn_str=tn_str sep sprintf("%.1f",tnc[m]>0?tns[m]/tnc[m]:0)
      w_str=w_str sep sprintf("%.1f",wc[m]>0?ws[m]/wc[m]:0)
      cclr_str=cclr_str sep sprintf("%.1f",cclrc[m]>0?cclrs[m]/cclrc[m]:0)
      cfew_str=cfew_str sep sprintf("%.1f",cfewc[m]>0?cfews[m]/cfewc[m]:0)
      csct_str=csct_str sep sprintf("%.1f",csctc[m]>0?cscts[m]/csctc[m]:0)
      cbkn_str=cbkn_str sep sprintf("%.1f",cbknc[m]>0?cbkns[m]/cbknc[m]:0)
      covc_str=covc_str sep sprintf("%.1f",covcc[m]>0?covcs[m]/covcc[m]:0)
      hihr_str=hihr_str sep sprintf("%d",hihr[m])
    }
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.1f\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
      city,state,lat,lon,region,t_str,d_str,h_str,
      elev,td_str,tn_str,w_str,
      cclr_str,cfew_str,csct_str,cbkn_str,covc_str,hihr_str
  }' "$csvfile" >> "$TSV_FILE"

  echo "  Processed: $city"
done

city_count=$(wc -l < "$TSV_FILE")
echo ""
echo "Processed $city_count cities"
echo ""

# ============================================================
# Step 3: Generate JSON from TSV
# ============================================================
echo "=== Generating city_data.json ==="

awk 'BEGIN{
  FS="\t"
  printf "{\n\"cities\":[\n"
}
{
  if(NR>1) printf ",\n"
  printf "  {\"city\":\"%s\",\"state\":\"%s\",\"lat\":%s,\"lon\":%s,\"region\":\"%s\",",$1,$2,$3,$4,$5
  printf "\"monthlyTemp\":[%s],",$6
  printf "\"monthlyDewp\":[%s],",$7
  printf "\"monthlyHI\":[%s],",$8
  printf "\"elevation\":%s,",$9
  printf "\"monthlyTempDay\":[%s],",$10
  printf "\"monthlyTempNight\":[%s],",$11
  printf "\"monthlyWind\":[%s],",$12
  printf "\"monthlyCloudClear\":[%s],",$13
  printf "\"monthlyCloudFew\":[%s],",$14
  printf "\"monthlyCloudSct\":[%s],",$15
  printf "\"monthlyCloudBkn\":[%s],",$16
  printf "\"monthlyCloudOvc\":[%s],",$17
  printf "\"monthlyHighHIHours\":[%s]}",$18
}
END{
  printf "\n]\n}\n"
}' "$TSV_FILE" > "$OUTPUT"

echo "Done! Output: $OUTPUT"
echo "Cities in dataset: $city_count"
