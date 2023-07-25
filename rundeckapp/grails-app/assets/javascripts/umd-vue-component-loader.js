function createVueComponentsFromUmdModule(moduleName) {
  //console.log("attempting to init vue components for module: " + moduleName)
  (async () => {
    const components = window[moduleName]
    let vue = await new Promise(res => {
      Object.defineProperty(window._rundeck.rootStore.ui, "app", {set: res});
    });
    for (let [k, comp] of Object.entries(components)) {
      //console.log('initing: ' + k); //uncomment for debug message
      if (!vue) {return}
      vue.component(k, comp)
    }
  })();
}
