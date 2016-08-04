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

    public void query_boinc_daemon(GLib.InetSocketAddress addr, string password, XMLCallback ? request_writer, XMLCallback ? success_response_handler = null) throws BoincError, GLib.IOError, GLib.Error {
        var client = new GLib.SocketClient () ;
        SocketConnection conn ;
        try {
            conn = client.connect (addr) ;
        } catch {
            throw new BoincError.CONNECT_ERROR ("Failed to connect to [%s]:%u".printf (addr.address.to_string (), addr.port)) ;
        }
        var istream = new GLib.DataInputStream (conn.input_stream) ;

        var req_doc = new GXml.TDocument () ;

        var req_root = req_doc.create_element ("boinc_gui_rpc_request") ;
        req_doc.children.add (req_root) ;

        req_root.children.add (req_doc.create_element ("auth1")) ;
        bool auth_complete = false ;
        bool request_sent = false ;
        while( true ){
            if( req_root.children.size == 0 ){
                return ;
            }
            var req_string = req_doc.to_string ().replace ("<?xml version=\"1.0\"?>\n", "") ;
            req_root.children.clear () ;

            uint8[] data = req_string.data ;
            data += 3 ;
            conn.output_stream.write (data) ;

            size_t s = 1 ;
            var recvdata = istream.read_until ("\x03", out s).strip () ;

            var rsp_doc = new GXml.TDocument.from_string (recvdata.replace ("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>", "")) ;
            if( rsp_doc.children.size == 0 ){
                throw new BoincError.INVALID_XML ("Empty response XML document.") ;
            }
            var root_node = rsp_doc.children.get (0) ;
            if( root_node.name != "boinc_gui_rpc_reply" ){
                throw new BoincError.INVALID_XML ("Invalid response XML root node.") ;
            }

            bool auth_in_progress = false ;
            bool done = false ;
            var b = new Gee.HashMap<string, XMLCallbackWrapper>() ;
            b["nonce"] = new XMLCallbackWrapper ((ref child_node) => {
                var auth2node = req_doc.create_element ("auth2") ;
                req_root.children.add (auth2node) ;

                var nonce_node = req_doc.create_element ("nonce_hash") ;
                nonce_node.children.add (req_doc.create_text (get_nonce_hash (password, child_node.value))) ;

                auth2node.children.add (nonce_node) ;

                req_root.children.add (auth2node) ;
                auth_in_progress = true ;
            }) ;
            b["unauthorized"] = new XMLCallbackWrapper (() => {
                throw new BoincError.INVALID_PASS ("Unauthorized") ;
            }) ;
            b["error"] = new XMLCallbackWrapper ((ref child_node) => {
                throw new BoincError.DAEMON_ERROR ("BOINC daemon returned error: %s".printf (child_node.value)) ;
            }) ;
            b["authorized"] = new XMLCallbackWrapper (() => {
                auth_complete = true ;
                auth_in_progress = true ;
            }) ;

            map_xml_node (ref root_node, ref b) ;

            if((auth_complete && request_sent) && success_response_handler != null ){
                success_response_handler (ref root_node) ;
                done = true ;
            }

            if( done || (auth_complete && success_response_handler == null)){
                return ;
            }

            if((auth_complete && !request_sent) && request_writer != null ){
                request_writer (ref req_root) ;
                request_sent = true ;
            }

            if( !auth_in_progress && !request_sent ){
                throw new BoincError.INVALID_XML ("Invalid XML response: %s".printf (recvdata)) ;
            }
        }
    }

}
