﻿// <copyright>
// Copyright 2013 by the Spark Development Network
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>
//
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.ServiceModel.Channels;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;

using Rock.Data;
using Rock.Model;
using Rock.Security;

namespace Rock.Rest.Filters
{
    /// <summary>
    /// 
    /// </summary>
    public class SecuredAttribute : ActionFilterAttribute
    {

        /// <summary>
        /// Occurs before the action method is invoked.
        /// </summary>
        /// <param name="actionContext">The action context.</param>
        public override void OnActionExecuting( HttpActionContext actionContext )
        {
            string controllerClassName = actionContext.ActionDescriptor.ControllerDescriptor.ControllerType.FullName;
            string actionMethod = actionContext.Request.Method.Method;
            string actionPath = actionContext.Request.GetRouteData().Route.RouteTemplate;

            using (new UnitOfWorkScope())
            {
                ISecured item = Rock.Web.Cache.RestActionCache.Read(actionMethod + actionPath);
                if (item == null)
                {
                    item = Rock.Web.Cache.RestControllerCache.Read( controllerClassName );
                    if (item == null)
                    {
                        item = new RestController();
                    }
                }
                
                Person person = null;

                if (actionContext.Request.Properties.Keys.Contains("Person"))
                {
                    person = actionContext.Request.Properties["Person"] as Person;
                }
                else
                {
                    var principal = actionContext.Request.GetUserPrincipal();
                    if ( principal != null && principal.Identity != null )
                    {
                        var userLoginService = new Rock.Model.UserLoginService();
                        var userLogin = userLoginService.GetByUserName( principal.Identity.Name );
                        if (userLogin != null)
                        {
                            person = userLogin.Person;
                            actionContext.Request.Properties.Add( "Person", person );
                        }
                    }
                }

                string action = actionMethod.Equals( "GET", StringComparison.OrdinalIgnoreCase ) ? 
                    Rock.Security.Authorization.VIEW : Rock.Security.Authorization.EDIT;
                if ( !item.IsAuthorized( action, person ) )
                {
                    actionContext.Response = new HttpResponseMessage( HttpStatusCode.Unauthorized );
                }
            }
        }
    }
}