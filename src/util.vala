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
    public delegate void XMLCallback(ref GXml.Node node) ;

    private class XMLCallbackWrapper {
        public XMLCallback func ;

        public XMLCallbackWrapper (owned XMLCallback func) {
            this.func = (owned) func ;
        }

    }

    public delegate void XMLStringCallback(string k) ;

    void map_xml_node(ref GXml.Node p, ref Gee.HashMap<string, XMLCallbackWrapper> b, XMLStringCallback ? cb_unknown_key = null) {
        foreach( var v in p.children ){
            var k = v.name ;
            var f = b[k] ;
            if( f == null ){
                if( cb_unknown_key != null ){
                    cb_unknown_key (k) ;
                }
            } else {
                f.func (ref v) ;
            }
        }
    }

}
