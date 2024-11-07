

def CreateTlClass [
    param: record,
] {
    return {
        className : $param.defines.view.0
        fields: []
        method: []
    }
}

def CreateTlClassMethod [
    param: record,
] {
    mut args = []
    for arg in $param.extends.args {
        $args = ($args | append  {
            argName : $arg.name,
            argType : $arg.type,
            argView : $arg.view
        })
    }

    return {
        methodName : $param.name,
        methodArgs : $args
    }
}

def TransTlClassMethod [
    param: record,
] {
    mut singleMethod_s = $"\t($param.methodName): function\("
    mut list_t = []
    for elt in $param.methodArgs {
        let tmp_s = $"($elt.argName): (match $elt.argType {
            "local" => $"($elt.argView)",
            "self" => $"($elt.argView)",
            _ => $"($elt.argView)",
        })"
        $list_t = ($list_t | append $tmp_s)
    }
    $singleMethod_s += ($list_t| str join ", " | $in + ")\n")
    return $singleMethod_s
}

def record2tlclass [
    param: record, 
] {
    if ($param.defines.type | get 0) == "doc.class" {
        # print $param
        mut tlClass = ( CreateTlClass $param)
        for elt in $param.fields {
            let fieldtype = match $elt.type { 
                "setmethod" => {
                    let method = (CreateTlClassMethod $elt)
                    $tlClass.method = ($tlClass.method | append $method)
                    $method
                },
                _ => 'otehr'
            }
            # print ($elt.type + $' ($fieldtype) ' )
        }

        # trans
        let classTitle = $"global type ($tlClass.className) = record\n" 
        mut tlClass_s = $classTitle 
        for elt in $tlClass.method {
            $tlClass_s += (
                TransTlClassMethod $elt
            )
        }

        $tlClass_s += "\nend"
        return  $tlClass_s
    }
}

def main [
    param: string, 
] {
    let doc_list = (open $param | where type == "type")

    mut class_list = []

    for elt in $doc_list {
        let tmp = (
            record2tlclass $elt
        )
        $class_list = ($class_list | append $tmp)
        # print $tmp
    }

    $class_list | save -f tl_define.d.tl

    # print $class_list
}
