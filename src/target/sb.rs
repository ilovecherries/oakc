use super::Target;
use std::{
    env::consts::EXE_SUFFIX,
    fs::{remove_file, write},
    io::{Error, ErrorKind, Result, Write},
    process::{Command, Stdio},
};

pub struct SB;
impl Target for SB {
    fn get_name(&self) -> char {
        's'
    }

    fn is_standard(&self) -> bool {
        true
    }

    fn std(&self) -> String {
        String::from(include_str!("std/std.prg"))
    }

    fn core_prelude(&self) -> String {
        String::from(include_str!("core/core.prg"))
    }

    fn core_postlude(&self) -> String {
        String::new()
    }

    fn begin_entry_point(&self, global_scope_size: i32, memory_size: i32) -> String {
        format!(
            "MACHINE_NEW {}, {}\n",
            global_scope_size,
            global_scope_size + memory_size,
        )
    }

    fn end_entry_point(&self) -> String {
        String::from("MACHINE_DROP\nSTOP\n")
    }

    fn establish_stack_frame(&self, arg_size: i32, local_scope_size: i32) -> String {
        format!(
            "MACHINE_ESTABLISH_STACK_FRAME {}, {}\n",
            arg_size, local_scope_size
        )
    }

    fn end_stack_frame(&self, return_size: i32, local_scope_size: i32) -> String {
        format!(
            "MACHINE_END_STACK_FRAME {}, {}\n",
            return_size, local_scope_size
        )
    }

    fn load_base_ptr(&self) -> String {
        String::from("MACHINE_LOAD_BASE_PTR\n")
    }

    fn push(&self, n: f64) -> String {
        format!("MACHINE_PUSH {}\n", n)
    }

    fn add(&self) -> String {
        String::from("MACHINE_ADD\n")
    }

    fn subtract(&self) -> String {
        String::from("MACHINE_SUBTRACT\n")
    }

    fn multiply(&self) -> String {
        String::from("MACHINE_MULTIPLY\n")
    }

    fn divide(&self) -> String {
        String::from("MACHINE_DIVIDE\n")
    }

    fn sign(&self) -> String {
        String::from("MACHINE_SIGN\n")
    }

    fn allocate(&self) -> String {
        String::from("MACHINE_ALLOCATE\n")
    }

    fn free(&self) -> String {
        String::from("MACHINE_FREE\n")
    }

    fn store(&self, size: i32) -> String {
        format!("MACHINE_STORE {}\n", size)
    }

    fn load(&self, size: i32) -> String {
        format!("MACHINE_LOAD {}\n", size)
    }

    fn fn_header(&self, name: String) -> String {
        String::from("")
    }

    fn fn_definition(&self, name: String, body: String) -> String {
        format!("DEF {}\n{}\nEND\n", name, body)
    }

    fn call_fn(&self, name: String) -> String {
        format!("{}\n", name)
    }

    fn call_foreign_fn(&self, name: String) -> String {
        format!("{}\n", name)
    }

    fn begin_while(&self) -> String {
        String::from("WHILE MACHINE_POP#()\n")
    }

    fn end_while(&self) -> String {
        String::from("WEND\n")
    }

    fn compile(&self, code: String) -> Result<()> {
        if let Ok(_) = write("OUTPUT.prg", code) {
            return Result::Ok(());
        }
        Result::Err(Error::new(ErrorKind::Other, "error compiling "))
    }
}
