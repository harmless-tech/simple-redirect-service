const b = Bun.file("./redirects.json", {})
let map: Map<string, string> = new Map<string, string>();

try {
    let text = await b.text();
    let json = JSON.parse(text);

    if(json.redirects) {
        for(let key in json.redirects) {
            map.set(key, json.redirects[key]);
            console.log(`Added permanent redirect: ${key} => ${json.redirects[key]}`);
        }
    }
}
catch {
    console.warn("Could not find or load file './redirects.json'.");
}

export default map;
