using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using NLua;

namespace DSTModManagerAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<object> Get()
        {
            List<string> ModList = new List<string>();
            using (Lua lua = new Lua())
            {
                lua.DoFile(System.IO.Path.Combine("LuaScripts", "config.lua"));
                var modMgrFilePath = System.IO.Path.Combine("LuaScripts", "getmods.lua");
                //if (System.IO.File.Exists(modMgrFilePath))
                object[] result = lua.DoFile(modMgrFilePath);
                if (result.Length > 0 && result[0] is LuaTable)
                {
                    LuaTable table = result[0] as LuaTable;
                    foreach (object kvp in table)
                    {
                        KeyValuePair<object, object>? kvpObj = kvp as KeyValuePair<object, object>?;
                        if (kvpObj.HasValue)
                        {
                            ModList.Add(kvpObj.Value.ToString());
                        }
                    }
                }
            }
            return ModList;
        }
    }
}
