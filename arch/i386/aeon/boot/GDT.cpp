#include <aeon/Types.h>
#include <aeon/boot/GDT.h>

/**
 * @brief Struct for specifying a GDT entry
 */
struct GDTEntry {
    // Limit
    aeon::Word LimitLow;

    // Segments
    aeon::Word BaseLow;
    aeon::Byte BaseMiddle;

    // Access modes
    aeon::Byte Access;
    aeon::Byte Granularity;
    aeon::Byte BaseHigh;
} __attribute__((packed));

/**
 * @brief GDT pointer
 */
struct GDTPtr {
    aeon::Word Limit;
    aeon::DWord Base;
} __attribute__((packed));

extern "C" {

/**
 * @brief This is the value that will be accessed by the assembler for loading GDT
 */
GDTPtr __gdt_ptr;

/**
 * @brief Flush gdt changes to the register
 */
extern void __gdt_flush();
}

namespace aeon {

/**
 * @brief Configure a single GDT entry
 *
 * @param entry Entry reference
 * @param base Base address
 * @param limit Limit
 * @param access Access permissions
 * @param gran Granularity
 */
void ConfigureGDTEntry(GDTEntry& entry, unsigned long base, unsigned long limit, aeon::Byte access, aeon::Byte gran) {
    // Base Address
    entry.BaseLow = (base & 0xFFFF);
    entry.BaseMiddle = (base >> 16) & 0xFF;
    entry.BaseHigh = (base >> 24) & 0xFF;

    // Limits
    entry.LimitLow = (limit & 0xFFFF);
    entry.Granularity = (limit >> 16) & 0X0F;

    // Granularity
    entry.Granularity |= (gran & 0xF0);

    // Access flags
    entry.Access = access;
}

void InitializeGDT() {
    static GDTEntry entries[6];

    // Setup pointers for global GDT pointer
    __gdt_ptr.Limit = (sizeof(GDTEntry) * 6) - 1;
    __gdt_ptr.Base = reinterpret_cast<aeon::DWord>(&entries);

    // Fill entries for GDT
    ConfigureGDTEntry(entries[0], 0, 0, 0, 0); // Null
    ConfigureGDTEntry(entries[1], 0, 0xFFFFFFFF, 0x9A, 0xCF); // Kernel code
    ConfigureGDTEntry(entries[2], 0, 0xFFFFFFFF, 0x92, 0xCF); // Kernel data
    ConfigureGDTEntry(entries[3], 0, 0xFFFFFFFF, 0xFA, 0xCF); // Userspace code
    ConfigureGDTEntry(entries[4], 0, 0xFFFFFFFF, 0xF2, 0xCF); // Userspace data

    // Flush GDT entries
    __gdt_flush();
}
} // namespace aeon
