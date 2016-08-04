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
    using GXml ;

    public errordomain BoincError {
        CONNECT_ERROR,
        INVALID_XML,
        INVALID_PASS,
        DAEMON_ERROR,
        NULL_ERROR
    }

    public enum Component {
        CPU,
        GPU,
        NETWORK
    }

    public enum RunMode {
        ALWAYS,
        AUTO,
        NEVER,
        RESTORE
    }

    public enum CpuSched {
        UNINITIALIZED,
        PREEMPTED,
        SCHEDULED
    }

    public enum ResultState {
        NEW,
        FILES_DOWNLOADING,
        FILES_DOWNLOADED,
        COMPUTE_ERROR,
        FILES_UPLOADING,
        FILES_UPLOADED,
        ABORTED,
        UPLOAD_FAILED
    }

    public enum Process {
        UNINITIALIZED = 0,
        EXECUTING = 1,
        SUSPENDED = 9,
        ABORT_PENDING = 5,
        QUIT_PENDING = 8,
        COPY_PENDING = 10
    }

    public class VersionInfo : GLib.Object {
        public int major { get ; set ; }
        public int minor { get ; set ; }
        public int release { get ; set ; }
    }

    string get_nonce_hash(string pass, string nonce) {
        return GLib.Checksum.compute_for_string (GLib.ChecksumType.MD5, nonce + pass) ;
    }

    public class HostInfo : GLib.Object {
        public int ? tz_shift { get ; set ; }
        public string ? domain_name { owned get ; set ; }
        public string ? serialnum { owned get ; set ; }
        public string ? ip_addr { owned get ; set ; }
        public string ? host_cpid { owned get ; set ; }

        public int ? p_ncpus { get ; set ; }
        public string ? p_vendor { owned get ; set ; }
        public string ? p_model { owned get ; set ; }
        public string ? p_features { owned get ; set ; }
        public double ? p_fpops { get ; set ; }
        public double ? p_iops { get ; set ; }
        public double ? p_membw { get ; set ; }
        public double ? p_calculated { get ; set ; }
        public bool ? p_vm_extensions_disabled { get ; set ; }

        public double ? m_nbytes { get ; set ; }
        public double ? m_cache { get ; set ; }
        public double ? m_swap { get ; set ; }

        public double ? d_total { get ; set ; }
        public double ? d_free { get ; set ; }

        public string ? os_name { owned get ; set ; }
        public string ? os_version { owned get ; set ; }
        public string ? product_name { owned get ; set ; }

        public string ? mac_address { owned get ; set ; }

        public string ? virtualbox_version { owned get ; set ; }
    }

    public class ProjectInfo : GLib.Object {
        public string name { owned get ; set ; }
        public string summary { owned get ; set ; }
        public string url { owned get ; set ; }
        public string general_area { owned get ; set ; }
        public string specific_area { owned get ; set ; }
        public string description { owned get ; set ; }
        public string home { owned get ; set ; }
        public string[] platforms { owned get ; set ; }
        public string image { owned get ; set ; }
    }

    public class AccountManagerInfo : GLib.Object {
        public string url { owned get ; set ; }
        public string name { owned get ; set ; }
        public bool have_credentials { get ; set ; }
        public bool cookie_required { get ; set ; }
        public string cookie_failure_url { owned get ; set ; }
    }

    public class Message : GLib.Object {
        public string name { owned get ; set ; }
        public int priority { get ; set ; }
        public int msg_number { get ; set ; }
        public string body { owned get ; set ; }
        public double dt { get ; set ; }
    }

    public class Result : GLib.Object {
        public string name { owned get ; set ; }
        public string wu_name { owned get ; set ; }
        public string platform { owned get ; set ; }
        public int version_num { get ; set ; }
        public string plan_class { owned get ; set ; }
        public string project_url { owned get ; set ; }
        public double final_cpu_time { get ; set ; }
        public double final_elapsed_time { get ; set ; }
        public int exit_status { get ; set ; }
        public int state { get ; set ; }
        public double report_deadline { get ; set ; }
        public double received_time { get ; set ; }
        public double estimated_cpu_time_remaining { get ; set ; }
        public double completed_time { get ; set ; }
    }

}
