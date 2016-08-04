/*
 * This file is part of boinc-gobject.
 *
 * https://github.com/skybon/boinc-gobject
 * Copyright (C) 2016 Artem Vorotnikov
 *
 * boinc-gobject is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation,
 * either version 3 of the License, or (at your option) any later version.
 *
 * boinc-gobject is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with boinc-gobject. If not, see <http://www.gnu.org/licenses/>.
 */

namespace Boinc{
    using GLib ;

    public class Client : GLib.Object {
        public GLib.InetSocketAddress addr { owned get ; construct set ; }
        public string password { owned get ; construct set ; }

        public Message[] get_messages(int seqno = 0) throws BoincError, GLib.IOError {
            Message[] v = {} ;

            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                var node = root_node.document.create_element ("get_messages") ;
                node.children.add (node.document.create_text ("%d".printf (seqno))) ;

                root_node.children.add (node) ;
            }, (ref root_node) => {
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["msgs"] = new XMLCallbackWrapper ((ref data_node) => {
                    var b2 = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                    b2["msg"] = new XMLCallbackWrapper ((ref entry_node) => {
                        var entry = new Message () ;

                        var b3 = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                        b3["name"] = new XMLCallbackWrapper ((ref node) => {
                            entry.name = node.value ;
                        }) ;
                        b3["pri"] = new XMLCallbackWrapper ((ref node) => {
                            if( node.value != "" ){
                                entry.priority = int.parse (node.value) ;
                            }
                        }) ;
                        b3["seqno"] = new XMLCallbackWrapper ((ref node) => {
                            if( node.value != "" ){
                                entry.msg_number = int.parse (node.value) ;
                            }
                        }) ;
                        b3["body"] = new XMLCallbackWrapper ((ref node) => {
                            string body = "" ;
                            foreach( var subnode in node.children ){
                                body += subnode.value.strip () ;
                            }
                            entry.body = body ;
                        }) ;
                        b3["time"] = new XMLCallbackWrapper ((ref node) => {
                            if( node.value != "" ){
                                entry.dt = int.parse (node.value) ;
                            }
                        }) ;

                        map_xml_node (ref entry_node, ref b3) ;

                        v += entry ;
                    }) ;
                    map_xml_node (ref data_node, ref b2) ;
                }) ;
                map_xml_node (ref root_node, ref b) ;
            }) ;
            return v ;
        }

        public ProjectInfo[] get_projects() throws BoincError, GLib.IOError {
            ProjectInfo[] v = {} ;
            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                root_node.children.add (root_node.document.create_element ("get_all_projects_list")) ;
            }, (ref root_node) => {
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["projects"] = new XMLCallbackWrapper ((ref data_node) => {
                    foreach( var entry_node in data_node.children ){
                        if( entry_node.name == "project" ){
                            var entry = new ProjectInfo () ;
                            foreach( var node in entry_node.children ){
                                switch( node.name ){
                                case "name":
                                    entry.name = node.value ;
                                    break ;
                                case "summary":
                                    entry.summary = node.value ;
                                    break ;
                                case "url":
                                    entry.url = node.value ;
                                    break ;
                                case "general_area":
                                    entry.general_area = node.value ;
                                    break ;
                                case "specific_area":
                                    entry.specific_area = node.value ;
                                    break ;
                                case "description":
                                    string body = "" ;
                                    foreach( var subnode in node.children ){
                                        body += subnode.value.strip () ;
                                    }
                                    entry.description = body ;
                                    break ;
                                case "home":
                                    entry.home = node.value ;
                                    break ;
                                case "platforms":
                                    string[] arr = {} ;
                                    foreach( var subnode in node.children ){
                                        if( subnode.name == "platform" ){
                                            if( subnode.value != "" ){
                                                arr += subnode.value ;
                                            }
                                        }
                                    }
                                    entry.platforms = arr ;
                                    break ;
                                case "image":
                                    entry.image = node.value ;
                                    break ;
                                }
                            }
                            v += entry ;
                        }
                    }
                }) ;
                map_xml_node (ref root_node, ref b) ;
            }) ;

            return v ;
        }

        public AccountManagerInfo get_account_manager_info() throws BoincError, GLib.IOError {
            var v = new AccountManagerInfo () ;

            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                root_node.children.add (root_node.document.create_element ("acct_mgr_info")) ;
            }, (ref root_node) => {
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["acct_mgr_info"] = new XMLCallbackWrapper ((ref data_node) => {
                    foreach( var node in data_node.children ){
                        switch( node.name ){
                        case "acct_mgr_url":
                            v.url = node.value ;
                            break ;
                        case "acct_mgr_name":
                            v.name = node.value ;
                            break ;
                        case "have_credentials":
                            v.have_credentials = true ;
                            break ;
                        case "cookie_required":
                            v.cookie_required = true ;
                            break ;
                        case "cookie_failure_url":
                            v.cookie_failure_url = node.value ;
                            break ;
                        }
                    }
                }) ;
                map_xml_node (ref root_node, ref b) ;
            }) ;

            return v ;
        }

        public int get_account_manager_rpc_status() throws BoincError, GLib.IOError {
            var v = 0 ;
            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                root_node.children.add (root_node.document.create_element ("acct_mgr_rpc_poll")) ;
            }, (ref root_node) => {
                var success = false ;
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["acct_mgr_rpc_reply"] = new XMLCallbackWrapper ((ref data_node) => {
                    foreach( var subnode in data_node.children ){
                        switch( subnode.name ){
                        case "error_num":
                            success = true ;
                            v = int.parse (subnode.value) ;
                            return ;
                        }
                    }
                }) ;
                map_xml_node (ref root_node, ref b) ;
                if( !success ){
                    throw new BoincError.NULL_ERROR ("Account manager RPC status not found in reply.") ;
                }
            }) ;
            return v ;
        }

        public void account_manager_rpc(string url, string name, string password) throws BoincError, GLib.IOError {
            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                var rpc_node = root_node.document.create_element ("acct_mgr_rpc") ;
                root_node.children.add (rpc_node) ;

                var url_node = root_node.document.create_element ("url") ;
                url_node.children.add (root_node.document.create_text (url)) ;
                rpc_node.children.add (url_node) ;

                var name_node = root_node.document.create_element ("name") ;
                name_node.children.add (root_node.document.create_text (name)) ;
                rpc_node.children.add (name_node) ;

                var password_node = root_node.document.create_element ("password") ;
                password_node.children.add (root_node.document.create_text (password)) ;
                rpc_node.children.add (password_node) ;
            }) ;
        }

        public VersionInfo exchange_versions() throws BoincError, GLib.IOError {
            var v = new VersionInfo () ;
            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                root_node.children.add (root_node.document.create_element ("exchange_versions")) ;
            }, (ref root_node) => {
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["server_version"] = new XMLCallbackWrapper ((ref data_node) => {
                    foreach( var child_node in data_node.children ){
                        switch( child_node.name ){
                        case "major":
                            v.major = int.parse (child_node.value) ;
                            break ;
                        case "minor":
                            v.minor = int.parse (child_node.value) ;
                            break ;
                        case "release":
                            v.release = int.parse (child_node.value) ;
                            break ;
                        }
                    }
                }) ;
                map_xml_node (ref root_node, ref b) ;
            }) ;

            return v ;
        }

        public Result[] get_results(bool active_only = false) throws BoincError, GLib.IOError {
            Result[] v = {} ;
            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                var subnode = root_node.document.create_element ("get_results") ;
                var subsubnode = root_node.document.create_element ("active_only") ;
                subsubnode.children.add (root_node.document.create_text (active_only ? "1" : "0")) ;
                subnode.children.add (subsubnode) ;

                root_node.children.add (subnode) ;
            }, (ref root_node) => {
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["results"] = new XMLCallbackWrapper ((ref data_node) => {
                    foreach( var entry_node in data_node.children ){
                        if( entry_node.name == "result" ){
                            var entry = new Result () ;

                            foreach( var subnode in entry_node.children ){
                                switch( subnode.name ){
                                case "name":
                                    entry.name = subnode.value ;
                                    break ;
                                case "wu_name":
                                    entry.wu_name = subnode.value ;
                                    break ;
                                case "platform":
                                    entry.platform = subnode.value ;
                                    break ;
                                case "version_num":
                                    entry.version_num = int.parse (subnode.value) ;
                                    break ;
                                case "plan_class":
                                    entry.plan_class = subnode.value ;
                                    break ;
                                case "project_url":
                                    entry.project_url = subnode.value ;
                                    break ;
                                case "final_cpu_time":
                                    entry.final_cpu_time = double.parse (subnode.value) ;
                                    break ;
                                case "final_elapsed_time":
                                    entry.final_elapsed_time = double.parse (subnode.value) ;
                                    break ;
                                case "exit_status":
                                    entry.exit_status = int.parse (subnode.value) ;
                                    break ;
                                case "state":
                                    entry.state = int.parse (subnode.value) ;
                                    break ;
                                case "report_deadline":
                                    entry.report_deadline = double.parse (subnode.value) ;
                                    break ;
                                case "received_time":
                                    entry.received_time = double.parse (subnode.value) ;
                                    break ;
                                case "estimated_cpu_time_remaining":
                                    entry.estimated_cpu_time_remaining = double.parse (subnode.value) ;
                                    break ;
                                case "completed_time":
                                    entry.completed_time = double.parse (subnode.value) ;
                                    break ;
                                }
                            }
                        }
                    }
                }) ;
                map_xml_node (ref root_node, ref b) ;
            }) ;

            return v ;
        }

        public void set_mode(Component component, RunMode mode, double duration = 0) throws BoincError, GLib.IOError {
            string comp_desc = "" ;
            switch( component ){
            case Component.CPU:
                comp_desc = "run" ;
                break ;
            case Component.GPU:
                comp_desc = "gpu" ;
                break ;
            case Component.NETWORK:
                comp_desc = "network" ;
                break ;
            }

            string mode_desc = "" ;
            switch( mode ){
            case RunMode.ALWAYS:
                mode_desc = "always" ;
                break ;
            case RunMode.AUTO:
                mode_desc = "auto" ;
                break ;
            case RunMode.NEVER:
                mode_desc = "never" ;
                break ;
            case RunMode.RESTORE:
                mode_desc = "restore" ;
                break ;
            }

            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                var node = root_node.document.create_element ("set_%s_mode".printf (comp_desc)) ;
                root_node.children.add (node) ;

                node.children.add (root_node.document.create_element (mode_desc)) ;
                var dur_node = root_node.document.create_element ("duration") ;
                dur_node.children.add (root_node.document.create_text ("%f".printf (duration))) ;
                node.children.add (dur_node) ;
            }, (ref root_node) => {
                var success = false ;
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["success"] = new XMLCallbackWrapper (() => { success = true ; }) ;
                if( !success ){
                    throw new BoincError.NULL_ERROR ("Account manager RPC status not found in reply.") ;
                }
            }) ;
        }

        public HostInfo get_host_info() {
            var v = new HostInfo () ;

            query_boinc_daemon (this.addr, this.password, (ref root_node) => {
                root_node.children.add (root_node.document.create_element ("get_host_info")) ;
            }, (ref root_node) => {
                var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
                b["host_info"] = new XMLCallbackWrapper ((ref data_node) => {
                    foreach( var node in data_node.children ){
                        switch( node.name ){
                        case "p_fpops":
                            v.p_fpops = double.parse (node.value) ;
                            break ;
                        case "p_iops":
                            v.p_iops = double.parse (node.value) ;
                            break ;
                        case "p_membw":
                            v.p_membw = double.parse (node.value) ;
                            break ;
                        case "p_calculated":
                            v.p_calculated = double.parse (node.value) ;
                            break ;
                        case "p_vm_extensions_disabled":
                            v.p_vm_extensions_disabled = bool.parse (node.value) ;
                            break ;
                        case "host_cpid":
                            v.host_cpid = node.value ;
                            break ;
                        case "product_name":
                            v.product_name = node.value ;
                            break ;
                        case "mac_address":
                            v.mac_address = node.value ;
                            break ;
                        case "domain_name":
                            v.domain_name = node.value ;
                            break ;

                        case "ip_addr":
                            v.ip_addr = node.value ;
                            break ;
                        case "p_vendor":
                            v.p_vendor = node.value ;
                            break ;
                        case "p_model":
                            v.p_model = node.value ;
                            break ;
                        case "os_name":
                            v.os_name = node.value ;
                            break ;
                        case "os_version":
                            v.os_version = node.value ;
                            break ;
                        case "virtualbox_version":
                            v.virtualbox_version = node.value ;
                            break ;
                        case "p_features":
                            v.p_features = node.value ;
                            break ;


                        case "timezone":
                            v.tz_shift = int.parse (node.value) ;
                            break ;
                        case "p_ncpus":
                            v.p_ncpus = int.parse (node.value) ;
                            break ;

                        case "m_nbytes":
                            v.m_nbytes = double.parse (node.value) ;
                            break ;
                        case "m_cache":
                            v.m_cache = double.parse (node.value) ;
                            break ;
                        case "m_swap":
                            v.m_swap = double.parse (node.value) ;
                            break ;
                        case "d_total":
                            v.d_total = double.parse (node.value) ;
                            break ;
                        case "d_free":
                            v.d_free = double.parse (node.value) ;
                            break ;
                        }
                    }
                }) ;
                map_xml_node (ref root_node, ref b) ;
            }) ;

            return v ;
        }

        public Client (GLib.InetSocketAddress a, string ? p = null) throws BoincError {
            Object (addr : a, password: p) ;
        }

    }

}
